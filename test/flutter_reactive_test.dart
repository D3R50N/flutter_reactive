import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'user_model.dart';
import 'user_store.dart';

void main() {
  group('Reactive core', () {
    test('Call', () async {
      final rb = true.rx;
      final st = rb.as((v) => v ? "Yes" : "No");

      st.listen(debugPrint);
      rb.toggle();
      rb.toggle();
      rb.toggle();
      rb.toggle();
    });
    test('Dependency', () {
      final store = UserStore().dep;
      store.updateName('Bob');
      expect(store.name.value, 'Bob');

      final store2 = UserStore().dep;
      expect(store2.name.value, 'Bob');

      store.dispose();
      expect(() => RxDep.of<UserStore>(), throwsException);

      final store3 = UserStore().dep;
      expect(store3.name.value, 'Alice');
    });
    test('ReactiveSubscription', () {
      final counter = 0.rx;
      var calls = 0;

      final sub = counter.listen((value) {
        calls++;
      });

      counter.increment();
      expect(calls, 1);

      sub.cancel();
      counter.increment();
      expect(calls, 1);
      expect(sub.currentValue, 2);
    });
    test('One-time reactions with once()', () {
      final counter = 0.rx;
      var calls = 0;

      counter.once((value) {
        calls++;
      });

      counter.increment();
      expect(calls, 1);

      counter.increment();
      expect(calls, 1);
    });
    test('Reactive object', () {
      final user = UserModel('Alice', 30).rx
          .require((u) => u.age >= 0, 'Age cannot be negative')
          .require((u) => u.name.trim().isNotEmpty, 'Name cannot be empty');

      user.listen((value) {
        debugPrint('User updated: $value');
      });

      try {
        user.mutate((u) {
          u.name = 'Bob';
          u.age = 25;
        });

        user.value.age++;

        user.mutate((u) {
          u.age = 46;
        });
      } on ReactiveValidatorError catch (e) {
        debugPrint(e.message);
        debugPrint('${e.value}');
      }
    });
    test('Emit stream direclty', () async {
      final name = 'max'.rx;
      final list = name.as((n) => n.split(''));
      final t = list.transform(reverse: true);

      t.listen((value) {
        debugPrint('value $value');
      });

      t.stream.listen((value) {
        debugPrint('stream value $value');
      });

      // name.set('andy');
    });

    test('listen can emit the current value immediately', () {
      final counter = 3.rx;
      final emitted = <int>[];

      counter.listen((value) {
        emitted.add(value);
      }, true);

      counter.increment(2);

      expect(emitted, [3, 5]);
    });

    test('compute tracks nested dependencies and stays read-only', () {
      final quantity = 1.rx;
      final price = 4.5.rx;
      final total = compute(() => compute(() => 0) + quantity * price);
      final emitted = <num>[];

      total.listen((value) {
        emitted.add(value);
      });

      quantity.increment();
      price.increment(0.5);

      expect(total.value, 10);
      expect(emitted, [9, 10]);
      expect(() => total.value = 12, throwsA(isA<StateError>()));
    });

    test('compute rebuilds dynamic dependencies when branches change', () {
      final useA = true.rx;
      final a = 1.rx;
      final b = 10.rx;
      final selected = compute(() => useA.value ? a.value : b.value);

      expect(selected.value, 1);

      a.value = 2;
      expect(selected.value, 2);

      useA.value = false;
      expect(selected.value, 10);

      a.value = 3;
      expect(selected.value, 10);

      b.value = 11;
      expect(selected.value, 11);
    });

    test('two computed values declared sequentially keep their listeners', () {
      final source = 1.rx;
      final a = compute(() => source.value * 2);
      final b = compute(() => a.value + 1);
      final aEmitted = <int>[];
      final bEmitted = <int>[];

      a.listen((value) {
        aEmitted.add(value);
      });
      b.listen((value) {
        bEmitted.add(value);
      });

      source.value = 2;
      source.value = 3;

      expect(a.value, 6);
      expect(b.value, 7);
      expect(aEmitted, [4, 6]);
      expect(bEmitted, [5, 7]);
    });

    test('combine5 updates from all sources and is read-only', () {
      final drink = 'Latte'.rx;
      final qty = 1.rx;
      final member = false.rx;
      final rush = false.rx;
      final note = ''.rx;

      final summary = combine5(drink, qty, member, rush, note, (
        drink,
        qty,
        member,
        rush,
        note,
      ) {
        final cleanNote = note.isEmpty ? 'no note' : note;
        return '$qty x $drink | ${member ? 'member' : 'guest'} | '
            '${rush ? 'rush' : 'standard'} | $cleanNote';
      });

      qty.increment(2);
      member.enable();
      rush.enable();
      note.value = 'oat milk';

      expect(summary.value, '3 x Latte | member | rush | oat milk');
      expect(() => summary.value = 'Override', throwsA(isA<StateError>()));
    });

    test('transactions support rollback and manual rollback', () async {
      final stock = <String, int>{'Latte': 3}.rx.require(
        (value) => value['Latte']! >= 0,
        'Stock cannot be negative',
      );
      final sold = <String>[].rxNonStrict;

      await Reactive.run(() {
        stock.put('Latte', stock.get('Latte')! - 2);
        sold.add('ticket-1');
      });

      expect(stock.get('Latte'), 1);
      expect(sold.value, ['ticket-1']);

      await Reactive.run(() {
        stock.put('Latte', stock.get('Latte')! - 4);
        sold.add('ticket-2');
      }, onError: (_) {});

      expect(stock.get('Latte'), 1);
      expect(sold.value, ['ticket-1']);

      final transaction = await Reactive.run(() {
        stock.put('Latte', stock.get('Latte')! - 1);
        sold.add('ticket-3');
      }, rollbackOnError: false);

      expect(stock.get('Latte'), 0);
      expect(sold.value, ['ticket-1', 'ticket-3']);

      transaction.rollback();

      expect(stock.get('Latte'), 1);
      expect(sold.value, ['ticket-1']);
    });

    test('save restore and helper extensions behave as expected', () async {
      final note = '  latte  '.rx;
      final queue = <int>[2, 5, 1].rxNonStrict;
      final stock = <String, int>{'Latte': 2}.rx;
      final counter = 0.rx;
      var whenHits = 0;

      counter.when((value) => value == 2, (_) {
        whenHits++;
      });

      note.trim();
      note.toUpper();
      note.append(' READY');
      expect(note.value, 'LATTE READY');

      queue.addFirst(9);
      queue.sort();
      expect(queue.value, [1, 2, 5, 9]);
      expect(queue.at(1), 2);
      expect(queue.atOrNull(10), isNull);

      final evenQueue = queue.transform(filter: (value) => value.isEven);
      queue.add(6);
      expect(evenQueue.value, [2, 6]);

      stock.put('Cookie', 4);
      stock.remove('Latte');
      expect(stock.has('Cookie'), isTrue);
      expect(stock.get('Latte'), isNull);

      counter.value = 1;
      counter.save('draft');
      counter.increment();
      expect(whenHits, 1);
      counter.restore('draft');
      expect(counter.value, 1);

      await counter.setAsync(Future.value(7));
      expect(counter.value, 7);
    });
  });

  group('Reactive widgets', () {
    testWidgets('ReactiveBuilder auto-tracks reactive reads', (tester) async {
      final counter = 0.rx;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReactiveBuilder(() {
              return Text('count ${counter.value}');
            }),
          ),
        ),
      );

      expect(find.text('count 0'), findsOneWidget);

      counter.value = 4;
      await tester.pump();

      expect(find.text('count 4'), findsOneWidget);
    });

    testWidgets('ReactiveBuilder.watch2 rebuilds from both sources', (
      tester,
    ) async {
      final drink = 'Latte'.rx;
      final qty = 1.rx;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReactiveBuilder.watch2(drink, qty, (drink, qty) {
              return Text('$qty x $drink');
            }),
          ),
        ),
      );

      expect(find.text('1 x Latte'), findsOneWidget);

      qty.increment(2);
      await tester.pump();
      expect(find.text('3 x Latte'), findsOneWidget);

      drink.value = 'Matcha';
      await tester.pump();
      expect(find.text('3 x Matcha'), findsOneWidget);
    });

    testWidgets('ReactiveBuilder.stream exposes a StreamBuilder', (
      tester,
    ) async {
      final counter = 2.rx;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Scaffold(
            body: ReactiveBuilder.stream(counter, (context, snapshot) {
              return Text('count ${snapshot.data}');
            }),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('count 2'), findsOneWidget);

      counter.value = 5;
      await tester.pump(
        Duration(milliseconds: 10),
      ); // tiny wait to propagate stream update
      expect(find.text('count 5'), findsOneWidget);
    });

    testWidgets('ReactiveStateBuilder swaps local widget states', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Scaffold(
            body: ReactiveStateBuilder<bool>(
              initialState: false,
              states: {
                false:
                    (reactive) => ElevatedButton(
                      onPressed: reactive.enable,
                      child: const Text('Open'),
                    ),
                true:
                    (reactive) => ElevatedButton(
                      onPressed: reactive.disable,
                      child: const Text('Close'),
                    ),
              },
            ),
          ),
        ),
      );

      expect(find.text('Open'), findsOneWidget);

      await tester.tap(find.text('Open'));
      await tester.pump();
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pump();
      expect(find.text('Open'), findsOneWidget);
    });
  });
}
