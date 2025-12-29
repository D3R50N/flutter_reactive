import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Nums changes', () {
    final counter = 0.reactive();
    counter.listen((v) {
      debugPrint("Counter: $v");
    });
    counter.increment(2);
    expect(counter.value, 2);
    counter.decrement(7);
    expect(counter.value, -5);
    counter.increment(0);
    expect(counter.value, -5);
    counter.increment(-1);
    expect(counter.value, -6);
  });

  test("List changes", () {
    final list = Reactive([]);
    list.listen((v) {
      debugPrint("List: $v");
    });
    list.add(1);
    list.add("jd");
    list.addToSet(1);
    list.remove(1);
    list.removeAll(1);
  });

  test("Combine reactives", () {
    final active = true.reactive();
    final count = 0.reactive();
    final message = ''.reactive();
    final status = Reactive.combine3(
      active,
      count,
      message,
      (isActive, cnt, msg) =>
          'Status: ${isActive ? "Active" : "Inactive"}, Count: $cnt, Message: $msg',
    );
    status.listen((value) {
      print(value);
    });

    active.disable();
    count.value = 10;
    message.value = 'Hello';
    active.toggle();
  });
}

class _Test extends StatefulWidget {
  const _Test();

  @override
  State<_Test> createState() => _TestState();
}

class _TestState extends State<_Test> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
