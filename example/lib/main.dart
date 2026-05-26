import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

import 'models/order_ticket.dart';
import 'page2.dart';

void main() {
  runApp(const CafeOpsApp());
}

class CafeOpsApp extends StatelessWidget {
  const CafeOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Reactive Cafe Ops',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const CafeOpsPage(),
    );
  }
}

class CafeOpsPage extends StatefulWidget {
  const CafeOpsPage({super.key});

  @override
  State<CafeOpsPage> createState() => _CafeOpsPageState();
}

class _CafeOpsPageState extends State<CafeOpsPage> {
  static const _draftId = 'order-draft';
  static const Map<String, double> _menuPrices = {
    'Espresso': 3.20,
    'Latte': 5.10,
    'Matcha': 5.80,
    'Cookie': 2.40,
  };

  int _nextTicketId = 1;
  late final TextEditingController _noteController;

  late final Reactive<String> selectedDrink = 'Latte'.rt;
  late final Reactive<int> quantity = 1.rt
      .require((value) => value > 0, 'Quantity must be at least 1')
      .require((value) => value <= 6, 'Quantity is capped at 6 per ticket');
  late final Reactive<bool> isMember = false.rt;
  late final Reactive<bool> rushMode = false.rt;
  late final Reactive<String> customerNote = ''.rt;
  late final Reactive<String> queueFilter = 'all'.rt;
  late final Reactive<String> savedDraftLabel = 'Draft: none'.rtNonStrict;
  late final Reactive<String> serviceSignal = 'Counter ready'.rtNonStrict;
  late final Reactive<int> serviceSignalHits = 0.rtNonStrict;
  late final Reactive<List<String>> activityLog = <String>[].rtNonStrict;
  late final Reactive<Map<String, int>> stockByDrink = <String, int>{
    'Espresso': 14,
    'Latte': 9,
    'Matcha': 7,
    'Cookie': 18,
  }.rtNonStrict.require(
    (stock) => stock.values.every((value) => value >= 0),
    'Stock cannot go negative',
  );
  late final Reactive<List<OrderTicket>> tickets = <OrderTicket>[].rtNonStrict;

  late final Reactive<double> unitPrice = Reactive.compute(
    () => _menuPrices[selectedDrink.value]!,
  );
  late final Reactive<double> subtotal = Reactive.compute(
    () => unitPrice.value * quantity.value,
  );
  late final Reactive<double> discount = Reactive.compute(
    () => isMember.value ? subtotal.value * 0.12 : 0,
  );
  late final Reactive<double> total = Reactive.compute(
    () => subtotal.value - discount.value,
  );
  late final Reactive<int> etaMinutes = Reactive.compute(
    () => (rushMode.value ? 6 : 3) + quantity.value * 2,
  );
  late final Reactive<String> orderHeadline = Reactive.combine3(
    selectedDrink,
    quantity,
    isMember,
    (drink, qty, member) =>
        '$qty x $drink${member ? ' with member discount' : ''}',
  );
  late final Reactive<List<OrderTicket>> openTickets = tickets.transform(
    filter: (ticket) => !ticket.ready,
    reverse: true,
  );
  late final Reactive<List<OrderTicket>> readyTickets = tickets.transform(
    filter: (ticket) => ticket.ready,
    reverse: true,
  );

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: customerNote.value);

    selectedDrink.listen((drink) {
      _addLog('Composer ready for $drink.');
    }, true);

    serviceSignal.listen((signal) {
      serviceSignalHits.increment();
      _addLog('Service signal: $signal.');
    }, true);

    quantity.when((value) => value >= 4, (value) {
      _addLog('Large order alert: $value items on one ticket.');
    });

    quantity.throttle(400, (value) {
      _addLog('Quick edit: quantity adjusted to $value.');
    });

    customerNote.debounce(600, (value) {
      final note = value.trim();
      if (note.isNotEmpty) {
        _addLog('Debounced note saved: "$note".');
      }
    });

    customerNote.listen((value) {
      if (_noteController.text == value) return;
      _noteController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }, true);
  }

  @override
  void dispose() {
    _noteController.dispose();
    selectedDrink.dispose();
    quantity.dispose();
    isMember.dispose();
    rushMode.dispose();
    customerNote.dispose();
    queueFilter.dispose();
    savedDraftLabel.dispose();
    serviceSignal.dispose();
    serviceSignalHits.dispose();
    activityLog.dispose();
    stockByDrink.dispose();
    tickets.dispose();
    unitPrice.dispose();
    subtotal.dispose();
    discount.dispose();
    total.dispose();
    etaMinutes.dispose();
    orderHeadline.dispose();
    openTickets.dispose();
    readyTickets.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    final now = DateTime.now();
    final stamp =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    activityLog.mutate((items) {
      items.add('[$stamp] $message');
      if (items.length > 40) {
        items.removeRange(0, items.length - 40);
      }
    });
  }

  Future<void> _submitTicket() async {
    final drink = selectedDrink.value;
    final qty = quantity.value;
    final note = customerNote.trimmed;
    var submitted = false;

    await Reactive.run(
      () {
        stockByDrink.put(drink, (stockByDrink.get(drink) ?? 0) - qty);
        tickets.addFirst(
          OrderTicket(
            id: _nextTicketId++,
            drink: drink,
            quantity: qty,
            note: note,
            member: isMember.value,
            rush: rushMode.value,
            ready: false,
            createdAt: DateTime.now(),
          ),
        );
        customerNote.clear();
        quantity.value = 1;
        rushMode.disable();
        submitted = true;
      },
      onError: (error) {
        _addLog('Submit failed: ${_formatError(error)}');
      },
    );

    if (submitted) {
      serviceSignal.value = 'Order sent to bar';
      _addLog('Submitted ticket for $drink x$qty.');
    }
  }

  void _saveDraft() {
    selectedDrink.save(_draftId);
    quantity.save(_draftId);
    isMember.save(_draftId);
    rushMode.save(_draftId);
    customerNote.save(_draftId);
    savedDraftLabel.value = 'Draft: ${quantity.value} x ${selectedDrink.value}';
    serviceSignal.value = 'Draft saved';
  }

  void _restoreDraft() {
    selectedDrink.restore(_draftId);
    quantity.restore(_draftId);
    isMember.restore(_draftId);
    rushMode.restore(_draftId);
    customerNote.restore(_draftId);
    serviceSignal.value = 'Draft restored';
    _addLog('Restored saved order draft.');
  }

  void _clearDraft() {
    selectedDrink.unsave(_draftId);
    quantity.unsave(_draftId);
    isMember.unsave(_draftId);
    rushMode.unsave(_draftId);
    customerNote.unsave(_draftId);
    savedDraftLabel.value = 'Draft: none';
    serviceSignal.value = 'Draft cleared';
  }

  void _appendDefaultNote() {
    if (customerNote.isEmpty) {
      customerNote.value = 'extra hot';
      return;
    }
    customerNote.append(', oat milk');
  }

  void _trimNote() {
    customerNote.trim();
  }

  void _ringPickupBell() {
    serviceSignal.value = 'Pickup ready';
  }

  void _restock(String drink) {
    stockByDrink.put(drink, (stockByDrink.get(drink) ?? 0) + 3);
    _addLog('Restocked $drink by 3 units.');
  }

  void _toggleReady(OrderTicket ticket) {
    final index = tickets.value.indexWhere((item) => item.id == ticket.id);
    if (index == -1) return;

    final next = ticket.copyWith(ready: !ticket.ready);
    tickets[index] = next;

    if (next.ready) {
      serviceSignal.value = 'Pickup ready';
      _addLog('Ticket #${ticket.id} is ready.');
    } else {
      _addLog('Ticket #${ticket.id} moved back to in progress.');
    }
  }

  void _clearReadyTickets() {
    final removed = readyTickets.length;
    tickets.removeWhere((ticket) => ticket.ready);
    _addLog('Cleared $removed ready ticket(s).');
  }

  void _sortQueueByDrink() {
    tickets.sort((a, b) => a.drink.compareTo(b.drink));
    _addLog('Sorted queue alphabetically by drink.');
  }

  String _formatError(Object error) {
    if (error is ReactiveValidatorError) {
      return error.message;
    }
    return error.toString();
  }

  List<OrderTicket> _visibleTickets() {
    switch (queueFilter.value) {
      case 'open':
        return openTickets.toList();
      case 'ready':
        return readyTickets.toList();
      default:
        return tickets.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafe Ops with Flutter Reactive 1.0'),
        actions: [
          IconButton(
            tooltip: 'Open stream monitor',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (_) => StreamShowcasePage(
                        activityLog: activityLog,
                        orderHeadline: orderHeadline,
                        serviceSignal: serviceSignal,
                        stockByDrink: stockByDrink,
                        tickets: tickets,
                        total: total,
                      ),
                ),
              );
            },
            icon: const Icon(Icons.sensors),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Rxb(() {
                final nextTicket = openTickets.atOrNull(0);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Front counter snapshot',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(orderHeadline.value),
                    const SizedBox(height: 6),
                    Text(
                      'Total: \$${total.value.toStringAsFixed(2)} | '
                      'ETA: ${etaMinutes.value} min | '
                      'Open queue: ${openTickets.length}',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nextTicket == null
                          ? 'Next ticket: none yet'
                          : 'Next ticket: ${nextTicket.shortLabel}',
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compose an order',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Rxb.watch(
                    selectedDrink,
                    (drink) => DropdownButtonFormField<String>(
                      initialValue: drink,
                      decoration: const InputDecoration(labelText: 'Menu item'),
                      items:
                          _menuPrices.keys
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    '$item • \$${_menuPrices[item]!.toStringAsFixed(2)}',
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) selectedDrink.value = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          try {
                            quantity.dec();
                          } catch (e) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: const Text('-'),
                      ),
                      const SizedBox(width: 12),
                      Rxb.watch(quantity, (value) {
                        return Text(
                          'Quantity: $value',
                          style: Theme.of(context).textTheme.titleMedium,
                        );
                      }),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          try {
                            quantity.inc();
                          } catch (e) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: const Text('+'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Rxb.watch2(isMember, rushMode, (member, rush) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilterChip(
                          label: const Text('Member'),
                          selected: member,
                          onSelected: (_) => isMember.toggle(),
                        ),
                        FilterChip(
                          label: const Text('Rush prep'),
                          selected: rush,
                          onSelected: (_) => rushMode.toggle(),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Customer note',
                      hintText: 'eg. extra hot, no syrup',
                    ),
                    maxLines: 2,
                    onChanged: (value) => customerNote.value = value,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: _appendDefaultNote,
                        child: const Text('Add default note'),
                      ),
                      OutlinedButton(
                        onPressed: _trimNote,
                        child: const Text('Trim note'),
                      ),
                      OutlinedButton(
                        onPressed: customerNote.clear,
                        child: const Text('Clear note'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: _submitTicket,
                        child: const Text('Submit ticket'),
                      ),
                      FilledButton.tonal(
                        onPressed: _saveDraft,
                        child: const Text('Save draft'),
                      ),
                      FilledButton.tonal(
                        onPressed: _restoreDraft,
                        child: const Text('Restore draft'),
                      ),
                      OutlinedButton(
                        onPressed: _clearDraft,
                        child: const Text('Clear draft'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Rxb.watch(savedDraftLabel, (value) {
                    return Text(value);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explicit builder APIs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Rxb.watch(selectedDrink, (drink) {
                    return Text('watch: $drink selected');
                  }),
                  const SizedBox(height: 6),
                  Rxb.watch2(selectedDrink, quantity, (drink, qty) {
                    return Text('watch2: $qty x $drink');
                  }),
                  const SizedBox(height: 6),
                  Rxb.watch3(selectedDrink, quantity, isMember, (
                    drink,
                    qty,
                    member,
                  ) {
                    return Text(
                      'watch3: ${member ? 'Member' : 'Guest'} order for $qty x $drink',
                    );
                  }),
                  const SizedBox(height: 6),
                  Rxb.watch4(
                    selectedDrink,
                    quantity,
                    rushMode,
                    etaMinutes,
                    (drink, qty, rush, eta) {
                      return Text(
                        'watch4: $qty x $drink | ${rush ? 'Rush' : 'Standard'} | ETA $eta min',
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Rxb.watch5(
                    selectedDrink,
                    quantity,
                    isMember,
                    rushMode,
                    customerNote,
                    (drink, qty, member, rush, note) {
                      final cleanNote = note.trim().isEmpty ? 'No note' : note;
                      return Text(
                        'watch5: $qty x $drink | ${member ? 'member' : 'guest'} | ${rush ? 'rush' : 'standard'} | $cleanNote',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock and service signals',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Rxb.watch2(stockByDrink, serviceSignal, (
                    stock,
                    signal,
                  ) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...stock.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${entry.key}: ${entry.value} left',
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () => _restock(entry.key),
                                  child: const Text('Restock +3'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Signal: $signal'),
                        Text(
                          'Signal notifications: ${serviceSignalHits.value}',
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: _ringPickupBell,
                        child: const Text('Ring pickup bell'),
                      ),
                      OutlinedButton(
                        onPressed: () => serviceSignal.value = 'Counter ready',
                        child: const Text('Reset signal'),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kitchen queue',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Rxb(() {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text('All (${tickets.length})'),
                          selected: queueFilter.value == 'all',
                          onSelected: (_) => queueFilter.value = 'all',
                        ),
                        ChoiceChip(
                          label: Text('Open (${openTickets.length})'),
                          selected: queueFilter.value == 'open',
                          onSelected: (_) => queueFilter.value = 'open',
                        ),
                        ChoiceChip(
                          label: Text('Ready (${readyTickets.length})'),
                          selected: queueFilter.value == 'ready',
                          onSelected: (_) => queueFilter.value = 'ready',
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: _sortQueueByDrink,
                        child: const Text('Sort by drink'),
                      ),
                      OutlinedButton(
                        onPressed: _clearReadyTickets,
                        child: const Text('Clear ready'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Rxb(() {
                    final visible = _visibleTickets();
                    if (visible.isEmpty) {
                      return const Text('No tickets for this filter.');
                    }

                    return Column(
                      children:
                          visible.map((ticket) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '#${ticket.id} • ${ticket.shortLabel}',
                              ),
                              subtitle: Text(
                                [
                                  if (ticket.member) 'member',
                                  if (ticket.rush) 'rush',
                                  if (ticket.note.isNotEmpty) ticket.note,
                                ].join(' • ').ifEmpty('standard order'),
                              ),
                              trailing: FilledButton.tonal(
                                onPressed: () => _toggleReady(ticket),
                                child: Text(
                                  ticket.ready ? 'Reopen' : 'Mark ready',
                                ),
                              ),
                            );
                          }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Activity log',
                        style: Theme.of(context).textTheme.titleLarge,
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
                    height: 240,
                    child: Rxb.watch(activityLog, (items) {
                      if (items.isEmpty) {
                        return const Center(child: Text('No events yet.'));
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
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
