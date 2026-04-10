import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

class StreamShowcasePage extends StatelessWidget {
  const StreamShowcasePage({
    super.key,
    required this.transactionCounter,
    required this.status,
    required this.activityLog,
  });

  final Reactive<int> transactionCounter;
  final Reactive<String> status;
  final Reactive<List<String>> activityLog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ReactiveStreamBuilder Live View')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This page listens only through streams.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ReactiveStreamBuilder<String>(
                  reactive: status,
                  builder:
                      (context, snapshot) => Text(
                        snapshot.data ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ReactiveStreamBuilder<int>(
                  reactive: transactionCounter,
                  builder:
                      (context, snapshot) => Text(
                        'txCounter stream value: ${snapshot.data}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (Random().nextBool()) {
                      transactionCounter.inc(10);
                    } else {
                      transactionCounter.dec(10);
                    }
                  },
                  child: const Text('Increment or Decrement Counter'),
                ),
                ElevatedButton(
                  onPressed: () {
                    transactionCounter.save();
                  },
                  child: const Text('Save Counter State'),
                ),
                ElevatedButton(
                  onPressed: () {
                    transactionCounter.restore();
                  },
                  child: const Text('Restore Counter State'),
                ),
                ElevatedButton(
                  onPressed: () {
                    transactionCounter.unsave();
                  },
                  child: const Text('Clear Saved State'),
                ),
              ],
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ReactiveStreamBuilder<List<String>>(
                    reactive: activityLog,
                    builder: (context, snapshot) {
                      final items = snapshot.data ?? const <String>[];
                      if (items.isEmpty) {
                        return const Center(child: Text('No logs yet.'));
                      }
                      return ListView.builder(
                        reverse: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(items[index]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
