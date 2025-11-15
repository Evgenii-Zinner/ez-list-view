import 'package:ez_list_view/ez_list_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('EzListView Demo')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Problem: EzListView inside a Column',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // This would normally crash, but EzListView handles it.
            // In debug mode, you will see a red border and a console message.
            EzListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) => ListTile(
                title: Text('Item #$index'),
                dense: true,
              ),
            ),
            const Divider(height: 30, thickness: 2),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Solution: Wrap EzListView in an Expanded',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // To fix the layout permanently, wrap EzListView in a widget
            // that provides bounded height, like Expanded.
            Expanded(
              child: EzListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Corrected Item #$index'),
                  dense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
