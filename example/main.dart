import 'package:ez_list_view/ez_list_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EZ List View Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ListDemoScreen(),
    );
  }
}

class ListDemoScreen extends StatelessWidget {
  const ListDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('EZ List View Demo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '1. Safe in Column (Unbounded Height)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            // Normally crashes in Column, but safe here
            EzListView.builder(
              itemCount: 5,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics:
                  const NeverScrollableScrollPhysics(), // Let parent scroll
              itemBuilder: (context, index) => Card(
                color: Colors.green[100 * (index % 9 + 1)],
                child: ListTile(
                  title: Text('Item $index'),
                  leading: const Icon(Icons.list),
                ),
              ),
            ),

            const Divider(height: 32),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '2. Safe in Row (Unbounded Width)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            // Normally crashes in Row, but safe here
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  const Text('Start'),
                  EzListView.builder(
                    itemCount: 5,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) => Container(
                      width: 80,
                      margin: const EdgeInsets.all(4),
                      color: Colors.lime[100 * (index % 9 + 1)],
                      alignment: Alignment.center,
                      child: Text('H-Item $index'),
                    ),
                  ),
                  const Text('End'),
                ],
              ),
            ),

            const Divider(height: 32),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '3. Correct Usage (Wrapped in Expanded)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(
              height: 200, // Constrained parent
              child: Column(
                children: [
                  const Text('Header inside constrained column'),
                  Expanded(
                    child: EzListView.builder(
                      itemCount: 20,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) => Card(
                        color: Colors.teal[100 * (index % 9 + 1)],
                        child: ListTile(
                          title: Text('Expanded Item $index'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
