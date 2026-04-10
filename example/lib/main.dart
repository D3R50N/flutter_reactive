import 'dart:math';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ShowcasePage(),
    );
  }
}

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  final Random _random = Random();
  ReactiveTransaction? _pendingTransaction;

  late final Reactive<int> txCounter = 0.reactive().require(
    (v) => v >= 0,
    'Counter cannot be negative',
  );

  late final Reactive<List<int>> numbers = <int>[8, 3, 11, 2].reactive(false);
  late final Reactive<int> strictValue = 10.reactive();
  late final Reactive<int> nonStrictValue = 10.reactive(false);
  late final Reactive<int> strictNotifications = 0.reactive(false);
  late final Reactive<int> nonStrictNotifications = 0.reactive(false);
  late final Reactive<List<String>> activityLog = <String>[].reactive(false);

  late final Reactive<String> status =
      Reactive.combine2<int, List<int>, String>(
        txCounter,
        numbers,
        (counter, items) => 'Counter: $counter | Numbers: ${items.join(", ")}',
      );

  late final Reactive<String> strictStatus =
      Reactive.combine4<int, int, int, int, String>(
        strictValue,
        nonStrictValue,
        strictNotifications,
        nonStrictNotifications,
        (strict, nonStrict, strictHits, nonStrictHits) =>
            'strict=$strict ($strictHits notifications) • '
            'nonStrict=$nonStrict ($nonStrictHits notifications)',
      );

  late final void Function(int value) _strictListener;
  late final void Function(int value) _nonStrictListener;

  @override
  void initState() {
    super.initState();

    _strictListener = (_) => strictNotifications.increment();
    _nonStrictListener = (_) => nonStrictNotifications.increment();

    strictValue.listen(_strictListener);
    nonStrictValue.listen(_nonStrictListener);

    txCounter.when((v) => v != 0 && v % 5 == 0, (v) {
      _addLog('when() fired: txCounter reached $v');
    });

    _addLog('Showcase ready. Try each section to test v0.1.0 features.');
  }

  @override
  void dispose() {
    strictValue.unlisten(_strictListener);
    nonStrictValue.unlisten(_nonStrictListener);

    txCounter.dispose();
    numbers.dispose();
    strictValue.dispose();
    nonStrictValue.dispose();
    strictNotifications.dispose();
    nonStrictNotifications.dispose();
    activityLog.dispose();
    status.dispose();
    strictStatus.dispose();
    super.dispose();
  }

  String _formatError(Object error) {
    if (error is ReactiveValidatorError) {
      return error.message;
    }
    return error.toString();
  }

  void _addLog(String message) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    activityLog.mutate((logs) {
      logs.add('[$time] $message');
      if (logs.length > 30) {
        logs.removeRange(0, logs.length - 30);
      }
    });
  }

  Future<void> _runSuccessfulTransaction() async {
    final before = txCounter.value;
    _pendingTransaction = null;

    await Reactive.run(
      () {
        txCounter.inc(4);
        txCounter.dec(1);
      },
      onError: (error) {
        _addLog('Unexpected transaction error: ${_formatError(error)}');
      },
    );

    _addLog('Transaction success: $before -> ${txCounter.value}');
    if (mounted) setState(() {});
  }

  Future<void> _runAutoRollbackTransaction() async {
    final before = txCounter.value;
    _pendingTransaction = null;

    await Reactive.run(
      () {
        txCounter.inc(3);
        txCounter.dec(txCounter.value + 10); // force an invalid value (< 0)
      },
      onError: (error) {
        _addLog('Auto rollback: ${_formatError(error)}');
      },
    );

    _addLog('Auto rollback result: $before -> ${txCounter.value}');
    if (mounted) setState(() {});
  }

  Future<void> _runManualRollbackTransaction() async {
    final before = txCounter.value;

    _pendingTransaction = await Reactive.run(
      () {
        txCounter.inc(3);
        txCounter.dec(txCounter.value + 10); // force an invalid value (< 0)
      },
      rollbackOnError: false,
      onError: (error) {
        _addLog('No auto rollback: ${_formatError(error)}');
      },
    );

    _addLog(
      'Manual rollback pending: $before -> ${txCounter.value}. Tap "Rollback pending".',
    );
    if (mounted) setState(() {});
  }

  void _rollbackPendingTransaction() {
    final transaction = _pendingTransaction;
    if (transaction == null) {
      _addLog('No pending transaction to rollback.');
      return;
    }

    final before = txCounter.value;
    transaction.rollback();
    _pendingTransaction = null;
    _addLog('Manual rollback executed: $before -> ${txCounter.value}');
    updateState();
  }

  void _incrementStrictDemoValues() {
    strictValue.inc();
    nonStrictValue.inc();
    _addLog('Incremented strict and non-strict values.');
  }

  void _setSameValueOnBoth() {
    strictValue.value = strictValue.value;
    nonStrictValue.value = nonStrictValue.value;
    _addLog('Set same value on both (only non-strict notifies).');
  }

  void _resetStrictDemo() {
    strictValue.value = 10;
    nonStrictValue.value = 10;
    strictNotifications.value = 0;
    nonStrictNotifications.value = 0;
    _addLog('Strict mode demo reset.');
  }

  void _addRandomNumber() {
    final value = _random.nextInt(90) + 10;
    numbers.add(value);
    _addLog('Added $value to list.');
  }

  void _shuffleNumbers() {
    numbers.mutate((list) => list.shuffle(_random));
    _addLog('List shuffled.');
  }

  void _sortAscending() {
    numbers.sort();
    _addLog('List sorted ascending with ReactiveList.sort().');
  }

  void _sortDescending() {
    numbers.sort((a, b) => b.compareTo(a));
    _addLog('List sorted descending with custom compare.');
  }

  void _stepCounter() {
    txCounter.inc();
    _addLog('Manual increment: txCounter is now ${txCounter.value}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Reactive v0.1.0 Showcase'),
        actions: [
          IconButton(
            tooltip: 'Open stream page',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (_) => StreamShowcasePage(
                        transactionCounter: txCounter,
                        status: status,
                        activityLog: activityLog,
                      ),
                ),
              );
            },
            icon: const Icon(Icons.wifi_tethering),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New features in action',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Transactions, when(), strict mode behavior, and list sorting.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ReactiveBuilder<String>(
                  reactive: status,
                  builder: (value) => Text(value),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transactions + rollback + validator rename',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ReactiveBuilder<int>(
                      reactive: txCounter,
                      builder: (value) => Text('txCounter: $value'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _pendingTransaction == null
                          ? 'Pending rollback: none'
                          : 'Pending rollback: available',
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: _stepCounter,
                          child: const Text('Counter +1 (when test)'),
                        ),
                        FilledButton(
                          onPressed: _runSuccessfulTransaction,
                          child: const Text('Run success transaction'),
                        ),
                        FilledButton.tonal(
                          onPressed: _runAutoRollbackTransaction,
                          child: const Text('Fail + auto rollback'),
                        ),
                        FilledButton.tonal(
                          onPressed: _runManualRollbackTransaction,
                          child: const Text('Fail + manual rollback'),
                        ),
                        OutlinedButton(
                          onPressed:
                              _pendingTransaction == null
                                  ? null
                                  : _rollbackPendingTransaction,
                          child: const Text('Rollback pending'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Strict mode: `.reactive()` vs `.reactive(false)`',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ReactiveBuilder<String>(
                      reactive: strictStatus,
                      builder: (value) => Text(value),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed: _incrementStrictDemoValues,
                          child: const Text('Increment both'),
                        ),
                        FilledButton.tonal(
                          onPressed: _setSameValueOnBoth,
                          child: const Text('Set same value'),
                        ),
                        OutlinedButton(
                          onPressed: _resetStrictDemo,
                          child: const Text('Reset demo'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ReactiveList.sort()',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ReactiveBuilder<List<int>>(
                      reactive: numbers,
                      builder: (values) => Text(values.join(' • ')),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed: _addRandomNumber,
                          child: const Text('Add random'),
                        ),
                        FilledButton.tonal(
                          onPressed: _shuffleNumbers,
                          child: const Text('Shuffle'),
                        ),
                        FilledButton.tonal(
                          onPressed: _sortAscending,
                          child: const Text('Sort asc'),
                        ),
                        OutlinedButton(
                          onPressed: _sortDescending,
                          child: const Text('Sort desc'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Activity log',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: activityLog.clear,
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 220,
                      child: ReactiveBuilder<List<String>>(
                        reactive: activityLog,
                        builder: (items) {
                          if (items.isEmpty) {
                            return const Center(
                              child: Text(
                                'No events yet. Try the buttons above.',
                              ),
                            );
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
