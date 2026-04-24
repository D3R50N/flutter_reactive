// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';
import 'package:flutter_test/flutter_test.dart';

void dp(dynamic v) {
  debugPrint(v.toString());
}

void main() {
  test('Validator', () {
    final counter = 0.reactive();
    counter.require((v) => v > 0).require((v) => v < 4, "Te");

    counter.listen((v) {
      dp("Counter: $v");
    });

    counter.inc();
    counter.inc();
    counter.dec();
    counter.dec();
    counter.dec();
    counter.inc();
    counter.inc();
    try {
      counter.inc(); // throw
    } on ReactiveValidatorError catch (e) {
      print("Oups $e, value ${e.value} is not good");
    }
  });
  test('Nums changes', () {
    final counter = 0.reactive();
    counter.listen((v) {
      dp("Counter: $v");
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
    final list = Reactive(<int>[]);
    list.listen((v) {
      dp("List: $v");
    });

    final evenList = list.transform(filter: (element) => element % 2 == 0);
    evenList.listen((v) {
      dp("Even List: $v");
    });
    list.add(1);
    list.add(2);
    list.add(3);
    list.remove(2);
    list.add(4);
    list.add(5);
    list.add(6);
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

  group('Transactions', () {
    test('Transaction with no errors', () {
      final counter = 0.reactive().require(
        (v) => v >= 0,
        "Counter cannot be negative",
      );
      counter.listen((v) {
        dp("Counter: $v");
      });

      Reactive.run(
        () {
          counter.inc(5);
          counter.inc(3);
          counter.dec(2);
        },
        onError: (error) {
          print("Transaction failed with error: $error");
        },
      );

      expect(counter.value, 6);
    });

    test('Transaction with errors and rollback', () {
      final counter = 0.reactive().require(
        (v) => v >= 0,
        "Counter cannot be negative",
      );
      counter.listen((v) {
        dp("Counter: $v");
      });

      Reactive.run(
        () {
          counter.inc(5);
          counter.dec(10); // This will cause an error
          counter.inc(3); // This won't execute
        },
        rollbackOnError: true, // default
        onError: (error) {
          print("Transaction failed with error: $error");
        },
      );

      expect(counter.value, 0);
    });

    test('Transaction with errors and no rollback', () {
      final counter = 0.reactive().require(
        (v) => v >= 0,
        "Counter cannot be negative",
      );
      counter.listen((v) {
        dp("Counter: $v");
      });

      Reactive.run(
        () {
          counter.inc(5);
          counter.dec(10); // This will cause an error
          counter.inc(3); // This won't execute after the error
        },
        rollbackOnError: false,
        onError: (error) {
          print("Transaction failed with error: $error");
        },
      );

      expect(counter.value, 5);
    });

    test('Manual rollback after transaction', () async {
      final counter = 0.reactive().require(
        (v) => v >= 0,
        "Counter cannot be negative",
      );
      counter.listen((v) {
        dp("Counter: $v");
      });

      final transaction = await Reactive.run(
        () {
          counter.inc(5);
          counter.dec(10); // This will cause an error
          counter.inc(3); // This won't execute after the error
        },
        rollbackOnError: false,
        onError: (error) {
          print("Transaction failed with error: $error");
        },
      );

      expect(counter.value, 5);
      transaction.rollback();
      expect(counter.value, 0);
    });
  });

  test('When method', () {
    final counter = 0.reactive();
    counter.listen((v) {
      dp("Counter: $v");
    });

    counter.when((v) => v == 0, (_) => print("Counter is zero"));

    counter.inc();
    counter.dec();
  });

  test('list', () {
    final rList = [0, 2, 4, 3, 4, 5].reactive().require((l) => !l.contains(6));
    rList.listen((list) {
      dp('list : $list');
    });

    Reactive.run(() async {
      dp(rList.at(0));
      dp(rList.atOrNull(10));
      rList.addFirst(1);
      dp(rList[0]);
      rList.add(6);
      dp(rList.last);
      rList.remove(2);
      rList.removeAll(4);
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
