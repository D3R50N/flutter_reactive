import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

import 'page2.dart';

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

final counter = Reactive(0);
final counter2 = Reactive(10);
final isVisible = Reactive(true);
final name = Reactive('Andy');

// Combined reactive
final summary = Reactive.combine4(
  counter,
  counter2,
  isVisible,
  name,
  (c1, c2, visible, n) => '$n → ${c1 + c2} (${visible ? "visible" : "hidden"})',
);

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    counter.bind(this);
  }

  @override
  void dispose() {
    counter.unbind(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Rebuilt");
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Reactive')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Counter 1 simple: $counter',
              style: const TextStyle(fontSize: 18),
            ),
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
                ElevatedButton(
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => Page2())),
                  child: const Text('Go to page 2'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
