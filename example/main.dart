import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Reactive Example',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Basic reactives
  late final counter = react(0);
  late final counter2 = react(10);
  late final isVisible = react(true);
  late final name = react('Andy');

  // Combined reactive
  late final summary = Reactive.combine4(
    counter,
    counter2,
    isVisible,
    name,
    (c1, c2, visible, n) =>
        '$n → ${c1 + c2} (${visible ? "visible" : "hidden"})',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Reactive')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple reactive binding
            ReactiveBuilder<int>(
              reactive: counter,
              builder:
                  (value) => Text(
                    'Counter 1: $value',
                    style: const TextStyle(fontSize: 18),
                  ),
            ),

            const SizedBox(height: 8),

            ReactiveBuilder<int>(
              reactive: counter2,
              builder:
                  (value) => Text(
                    'Counter 2: $value',
                    style: const TextStyle(fontSize: 18),
                  ),
            ),

            const SizedBox(height: 8),

            ReactiveBuilder<bool>(
              reactive: isVisible,
              builder:
                  (value) => Text(
                    'Visible: $value',
                    style: const TextStyle(fontSize: 18),
                  ),
            ),

            const SizedBox(height: 8),

            ReactiveBuilder<String>(
              reactive: name,
              builder:
                  (value) => Text(
                    'Name: $value',
                    style: const TextStyle(fontSize: 18),
                  ),
            ),

            const Divider(height: 32),

            // Combined reactive
            ReactiveBuilder<String>(
              reactive: summary,
              builder:
                  (value) => Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),

            const Spacer(),

            // Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => counter.increment(),
                  child: const Text('+ Counter 1'),
                ),
                ElevatedButton(
                  onPressed: () => counter.decrement(),
                  child: const Text('- Counter 1'),
                ),
                ElevatedButton(
                  onPressed: () => counter2.increment(5),
                  child: const Text('+5 Counter 2'),
                ),
                ElevatedButton(
                  onPressed: () => isVisible.toggle(),
                  child: const Text('Toggle Visible'),
                ),
                ElevatedButton(
                  onPressed: () => name.append('!'),
                  child: const Text('Update Name'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
