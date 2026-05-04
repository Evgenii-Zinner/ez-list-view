import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A defensive, self-aware version of [ListView.builder].
///
/// Features:
/// *   **Crash Prevention:** Automatically detects unbounded constraints (e.g., inside [Column] or [Row]) and applies a safe fallback size.
/// *   **Debug Feedback:** In debug mode, displays a red border and logs a detailed error explaining the issue and the fix.
/// *   **Drop-in Replacement:** Supports the same API as [ListView.builder].
class EzListView extends StatelessWidget {
  /// See [ListView.builder.itemBuilder].
  final IndexedWidgetBuilder itemBuilder;

  /// See [ListView.builder.itemCount].
  final int? itemCount;

  /// See [ListView.builder.scrollDirection].
  final Axis scrollDirection;

  /// See [ListView.builder.reverse].
  final bool reverse;

  /// See [ListView.builder.controller].
  final ScrollController? controller;

  /// See [ListView.builder.primary].
  final bool? primary;

  /// See [ListView.builder.physics].
  final ScrollPhysics? physics;

  /// See [ListView.builder.shrinkWrap].
  final bool shrinkWrap;

  /// See [ListView.builder.padding].
  final EdgeInsetsGeometry? padding;

  /// See [ListView.builder.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// See [ListView.builder.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// See [ListView.builder.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// See [ListView.builder.cacheExtent].
  final double? cacheExtent;

  /// See [ListView.builder.semanticChildCount].
  final int? semanticChildCount;

  /// See [ListView.builder.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// See [ListView.builder.keyboardDismissBehavior].
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// See [ListView.builder.restorationId].
  final String? restorationId;

  /// See [ListView.builder.clipBehavior].
  final Clip clipBehavior;

  /// See [ListView.builder.findChildIndexCallback].
  final ChildIndexGetter? findChildIndexCallback;

  /// Creates a defensive, self-aware version of [ListView.builder].
  ///
  /// This widget automatically detects unbounded constraints and applies a fix
  /// to prevent layout crashes, providing detailed debugging information in
  /// debug mode.
  const EzListView.builder({
    super.key,
    required this.itemBuilder,
    this.itemCount,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.findChildIndexCallback,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isUnboundedHeight = constraints.maxHeight.isInfinite;
        final bool isUnboundedWidth = constraints.maxWidth.isInfinite;

        final bool isVertical = scrollDirection == Axis.vertical;

        // Determine if we need to apply a fix.
        // A ListView crashes if its scroll direction is unbounded and shrinkWrap is false,
        // OR if its cross-axis is unbounded.
        bool needsFixHeight = false;
        bool needsFixWidth = false;

        if (isVertical) {
          if (isUnboundedHeight && !shrinkWrap) needsFixHeight = true;
          if (isUnboundedWidth) needsFixWidth = true;
        } else {
          if (isUnboundedWidth && !shrinkWrap) needsFixWidth = true;
          if (isUnboundedHeight) needsFixHeight = true;
        }

        // If constraints are fine, just build the ListView.
        if (!needsFixHeight && !needsFixWidth) {
          return _buildListView();
        }

        // --- Apply safe fallback for unbounded constraints ---
        final mediaQuery = MediaQuery.of(context);

        final double fixedHeight;
        if (needsFixHeight) {
          if (isUnboundedHeight) {
            // Calculate a reasonable default height based on the screen size.
            final calculatedSafeHeight = mediaQuery.size.height -
                mediaQuery.padding.top -
                kToolbarHeight;
            fixedHeight = calculatedSafeHeight * 0.5; // Use 50% as a default
          } else {
            fixedHeight = constraints.maxHeight;
          }
        } else {
          fixedHeight = constraints.maxHeight;
        }

        final double fixedWidth;
        if (needsFixWidth) {
          if (isUnboundedWidth) {
            fixedWidth = mediaQuery.size.width * 0.5; // Use 50% as a default
          } else {
            fixedWidth = constraints.maxWidth;
          }
        } else {
          fixedWidth = constraints.maxWidth;
        }

        if (kDebugMode) {
          // Identify the parent widget causing the issue and report a detailed error.
          _reportError(context, needsFixWidth, needsFixHeight);

          // Wrap with a visual indicator to highlight the problematic widget.
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2.5),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: SizedBox(
              width: fixedWidth,
              height: fixedHeight,
              child: _buildListView(),
            ),
          );
        }

        // In release mode, apply the fix silently to prevent a crash.
        return SizedBox(
          width: fixedWidth,
          height: fixedHeight,
          child: _buildListView(),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      findChildIndexCallback: findChildIndexCallback,
    );
  }

  /// Reports a detailed error about which dimension was unbounded.
  void _reportError(BuildContext context, bool badWidth, bool badHeight) {
    String culprit = "an unknown parent";
    context.visitAncestorElements((element) {
      if (element.widget is Flex ||
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
          if (shrinkWrap == false &&
              ((scrollDirection == Axis.vertical && badHeight) ||
                  (scrollDirection == Axis.horizontal && badWidth)))
            ErrorHint(
              'Alternatively, if the list is intended to be as small as its children, set shrinkWrap: true.',
            ),
        ],
      ),
    );
  }
}
