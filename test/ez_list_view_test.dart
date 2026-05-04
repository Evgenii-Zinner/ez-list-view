import 'package:ez_list_view/ez_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EzListView Tests - Comprehensive Coverage', () {
    testWidgets('renders normally with bounded constraints',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              width: 400,
              child: EzListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('applies fix when inside Center inside Column (Unbounded)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Center(
                  child: EzListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Text('Item $index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets('renders normally directly in Scaffold body (Bounded)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets('applies fix when inside SingleChildScrollView -> Column',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  EzListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Text('Item $index'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets('renders normally inside Flexible in Column (Bounded)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Flexible(
                  child: EzListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Text('Item $index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets('applies fix when inside Padding -> Column',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: EzListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Text('Item $index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets('applies fix when inside ListTile title -> ListView',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ListTile(
                  title: EzListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => Text('Sub-item $index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets('applies fix when inside Wrap -> Column',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Wrap(
                  children: [
                    EzListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) =>
                          Text('Wrapped Item $index'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets(
        'shrinkWrap: true allows rendering in unbounded Column without fix',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EzListView.builder(
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (context, index) => Text('Item $index'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets('renders normally inside Container with fixed size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Container(
                height: 300,
                width: 300,
                child: EzListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets('applies fix inside Stack (unpositioned)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Stack(
                  children: [
                    EzListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => Text('Item $index'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
    });

    testWidgets('renders normally inside Positioned in Stack',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: EzListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Text('Item $index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);
    });
  });
}

bool _hasRedBorder(WidgetTester tester) {
  final containers = tester.widgetList<Container>(find.byType(Container));
  for (final c in containers) {
    if (c.decoration is BoxDecoration) {
      final box = c.decoration as BoxDecoration;
      if (box.border is Border) {
        final b = box.border as Border;
        if (b.top.color == Colors.red) return true;
      }
    }
  }
  return false;
}
