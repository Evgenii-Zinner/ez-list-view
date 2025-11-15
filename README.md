# EzListView

A defensive, self-aware `ListView.builder` for Flutter that prevents layout crashes from unbounded height constraints and educates the developer on the correct fix.

## The Problem It Solves

A common error for Flutter developers is placing a `ListView` inside a `Column` or other widget that provides infinite vertical space. This results in the dreaded "unbounded height" layout error, crashing the UI.

`EzListView` is a drop-in replacement for `ListView.builder` that anticipates this problem. Instead of crashing, it applies a safe, bounded height and provides clear, actionable feedback to help you fix the layout permanently.

## ✨ Features

*   **Crash Prevention:** Automatically detects when it's given unbounded height and applies a default height to prevent a layout crash.
*   **Developer Education:** In **debug mode**, it reports a detailed error to the console, identifying the parent widget causing the issue and explaining how to fix it (e.g., "wrap EzListView in an Expanded widget").
*   **Visual Debugging:** In **debug mode**, it renders a red border around itself to visually highlight exactly which list was automatically corrected.
*   **Drop-in Replacement:** Designed to be a direct substitute for `ListView.builder`, using the same constructor parameters.
*   **Release-Mode Safe:** In release builds, the debugging aids are disabled. The widget silently applies the height fix without any visual indicators or console logs.

## 📦 Installation

Run this command to add the package to your project:

```shell
flutter pub add ez_list_view
```

## 🚀 Usage

Use `EzListView.builder` exactly as you would use `ListView.builder`.

### Example: The "Wrong" Way (That Won't Crash)

If you place `EzListView` in a `Column`, it won't crash.

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ez_list_view/ez_list_view.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('EzListView Demo')),
        body: Column( // This Column provides unbounded height
          children: [
            const Text('Header Text'),
            // This would normally crash, but EzListView handles it.
            EzListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) => ListTile(
                title: Text('Item #$index'),
              ),
            ),
            const Text('Footer Text'),
          ],
        ),
      ),
    );
  }
}
```

In debug mode, this will result in:
1.  A **detailed error message** in your console explaining the problem and solution.
2.  A **red box** rendered around the `EzListView` on screen.

### Example: The "Correct" Way

To fix the layout permanently, wrap `EzListView` in a widget that provides bounded height, like `Expanded`.

```dart
// ...
body: Column(
  children: [
    const Text('Header Text'),
    // ✅ CORRECT: Expanded provides the ListView with finite space.
    Expanded(
      child: EzListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) => ListTile(
          title: Text('Item #$index'),
        ),
      ),
    ),
    const Text('Footer Text'),
  ],
),
//...
```

## 🤝 Contributing

Contributions are welcome! If you have a feature request, bug report, or want to contribute to the code, please feel free to open an issue or submit a pull request on the [GitHub repository](https://github.com/Evgenii-Zinner/ez_list_view/).

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.
