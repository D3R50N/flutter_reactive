// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    final message = ReactiveN<String>();
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

  test("User model", () {
    final user = ReactiveN<UserModel>();
    user.listen((value) {
      print("$value");
    });

    user.value = UserModel(name: "Max", age: 22);

    user.mutate((u) {
      u?.name = "oedo";
    });

  });
}

class UserModel {
  String name;
  int age;
  UserModel({required this.name, required this.age});

  @override
  String toString() => 'UserModel(name: $name, age: $age)';
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
