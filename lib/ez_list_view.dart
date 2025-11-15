import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A defensive, self-aware version of ListView.builder.
///
/// If it detects that its parent is providing unbounded constraints (e.g., inside
/// a Column or a Row), it automatically imposes bounded dimensions to prevent
/// a layout crash.
///
/// In debug mode, it also:
/// 1. Renders a red border around itself to visually identify that a fix was applied.
/// 2. Reports a detailed error to the console with the specific fix required.
class EzListView extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int? itemCount;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const EzListView.builder({
    super.key,
    required this.itemBuilder,
    this.itemCount,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isUnboundedHeight = constraints.maxHeight.isInfinite;
        final bool isUnboundedWidth = constraints.maxWidth.isInfinite;

        if (!isUnboundedHeight && !isUnboundedWidth) {
          return ListView.builder(
            itemBuilder: itemBuilder,
            itemCount: itemCount,
            padding: padding,
            physics: physics,
          );
        }

        Widget fixedListView = ListView.builder(
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          padding: padding,
          physics: physics,
        );

        final mediaQuery = MediaQuery.of(context);

        final double fixedHeight;
        if (isUnboundedHeight) {
          final calculatedSafeHeight =
              mediaQuery.size.height - mediaQuery.padding.top - kToolbarHeight;
          fixedHeight = calculatedSafeHeight * 0.5;
        } else {
          fixedHeight = constraints.maxHeight;
        }

        final double fixedWidth;
        if (isUnboundedWidth) {
          fixedWidth = mediaQuery.size.width * 0.5;
        } else {
          fixedWidth = constraints.maxWidth;
        }

        if (kDebugMode) {
          // Find the culprit and report a detailed error.
          _reportError(context, isUnboundedWidth, isUnboundedHeight);

          // Wrap with a visual indicator.
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2.5),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: SizedBox(
              width: fixedWidth,
              height: fixedHeight,
              child: fixedListView,
            ),
          );
        }

        // In release mode, just apply the fix silently.
        return SizedBox(
          width: fixedWidth,
          height: fixedHeight,
          child: fixedListView,
        );
      },
    );
  }

  /// Reports a detailed error about which dimension was unbounded.
  void _reportError(BuildContext context, bool badWidth, bool badHeight) {
    String culprit = "an unknown parent";
    context.visitAncestorElements((element) {
      if (element.widget is Flex ||
          element.widget is Column ||
          element.widget is Row ||
          element.widget is ListView ||
          element.widget is CustomScrollView) {
        culprit = element.widget.runtimeType.toString();
        return false;
      }
      return true;
    });

    String problematicDimension = "unknown";
    if (badWidth && badHeight) {
      problematicDimension = "width and height";
    } else if (badWidth) {
      problematicDimension = "width";
    } else {
      problematicDimension = "height";
    }

    FlutterError.reportError(
      FlutterErrorDetails(
        exception: 'EzListView: Unbounded $problematicDimension detected.',
        library: 'EzListView',
        context: ErrorDescription('while building EzListView'),
        informationCollector: () => [
          ErrorSummary('EzListView has applied an automatic layout fix.'),
          ErrorDescription(
            'This widget was placed directly inside a $culprit, which provides infinite $problematicDimension. '
            'This would normally cause a layout crash.',
          ),
          ErrorHint(
            'ACTION REQUIRED: For a permanent fix, you must wrap EzListView in a widget that provides bounded constraints, such as an Expanded or a SizedBox.',
          ),
        ],
      ),
    );
  }
}
