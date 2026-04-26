import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

import 'models/order_ticket.dart';

class StreamShowcasePage extends StatelessWidget {
  const StreamShowcasePage({
    super.key,
    required this.activityLog,
    required this.orderHeadline,
    required this.serviceSignal,
    required this.stockByDrink,
    required this.tickets,
    required this.total,
  });

  final Reactive<List<String>> activityLog;
  final Reactive<String> orderHeadline;
  final Reactive<String> serviceSignal;
  final Reactive<Map<String, int>> stockByDrink;
  final Reactive<List<OrderTicket>> tickets;
  final Reactive<double> total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen Stream Monitor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This page listens with streams and local reactive state only.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: StreamBuilder<String>(
                  stream: orderHeadline.stream,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? orderHeadline.value,
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: StreamBuilder<double>(
                  stream: total.stream,
                  builder: (context, snapshot) {
                    final value = snapshot.data ?? total.value;
                    return Text(
                      'Live total: \$${value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: StreamBuilder<String>(
                  stream: serviceSignal.stream,
                  builder: (context, snapshot) {
                    return Text('Signal: ${snapshot.data ?? serviceSignal.value}');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Local station mode with ReactiveStateBuilder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ReactiveStateBuilder<bool>(
              initialState: true,
              states: {
                true:
                    (reactive) => FilledButton.tonal(
                      onPressed: () => reactive.disable(),
                      child: const Text('Bar station is open'),
                    ),
                false:
                    (reactive) => OutlinedButton(
                      onPressed: () => reactive.enable(),
                      child: const Text('Reopen bar station'),
                    ),
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: StreamBuilder<List<OrderTicket>>(
                          stream: tickets.stream,
                          builder: (context, snapshot) {
                            final items = snapshot.data ?? tickets.value;
                            if (items.isEmpty) {
                              return const Center(
                                child: Text('No kitchen tickets yet.'),
                              );
                            }
                            return ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final ticket = items[index];
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('#${ticket.id} • ${ticket.shortLabel}'),
                                  subtitle: Text(ticket.ready ? 'Ready' : 'In progress'),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: StreamBuilder<Map<String, int>>(
                          stream: stockByDrink.stream,
                          builder: (context, snapshot) {
                            final stock = snapshot.data ?? stockByDrink.value;
                            return ListView(
                              children:
                                  stock.entries
                                      .map(
                                        (entry) => ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(entry.key),
                                          trailing: Text('${entry.value}'),
                                        ),
                                      )
                                      .toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: StreamBuilder<List<String>>(
                    stream: activityLog.stream,
                    builder: (context, snapshot) {
                      final items = snapshot.data ?? activityLog.value;
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
