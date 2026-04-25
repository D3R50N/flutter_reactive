# Flutter Reactive

Goodbye repetitive setState() calls! Welcome to Flutter Reactive.
No ChangeNotifier, no boilerplate — just Reactive values bound to States.

![logo.svg](logo.svg)

## Why Flutter Reactive ?

Let's be honest… writing `setState()` everywhere in 2026 feels old and most Flutter state management solutions are either too verbose (👀 ChangeNotifier, Provider…), too abstract (Riverpod, Bloc…), or come with too much features (Getx...).

**Flutter Reactive** takes a different approach:

👉 **Keep things simple, direct, and predictable.**

No unnecessary concepts, no boilerplate, no steep learning curve.
Flutter Reactive has **_zero_** external dependencies — just a plain Dart object that propagates its own changes. No context, no codegen, no framework lock-in.

## Comparison

| Specifications                    | Flutter Reactive | GetX | Provider | Bloc |
| --------------------------------- | ---------------- | ---- | -------- | ---- |
| Minimal boilerplate ?             | ✅               | ✅   | ❌       | ❌   |
| Easy to learn ?                   | ✅               | ✅   | ✅       | ❌   |
| Built-in reactivity (no setup) ?  | ✅               | ❌   | ❌       | ❌   |
| Automatic UI updates ?            | ✅               | ✅   | ❌       | ✅   |
| No external dependency required ? | ✅               | ❌   | ❌       | ❌   |
| Good for small apps ?             | ✅               | ✅   | ✅       | ❌   |
| Good for large apps ?             | ✅               | ❌   | ✅       | ✅   |
| Supports computed values easily ? | ✅               | ❌   | ❌       | ❌   |
| Supports side effects cleanly ?   | ✅               | ❌   | ❌       | ❌   |
| Transaction / rollback system ?   | ✅               | ❌   | ❌       | ❌   |
| Stream-friendly ?                 | ✅               | ✅   | ❌       | ✅   |
| No strict architecture required ? | ✅               | ✅   | ✅       | ❌   |
| Full control over state changes ? | ✅               | ❌   | ❌       | ❌   |

---

### Summary

- Flutter Reactive → simple, direct, no boilerplate, full control
- GetX → powerful but sometimes "magic" and less predictable
- Provider → simple but becomes verbose for complex reactivity
- Bloc → very structured, but heavy for small/medium apps

## Features

- Reactive variables (Reactive\<T>)
- Automatic State updates when data changes
- Manual listeners support
- Reactive streams support (`stream`)
- Conditional reactions with `when(...)`
- Transaction support with optional rollback (`Reactive.run(...)`)
- Built-in validation with `require(...)`
- Extensions on common types (num, bool, List, String, Map, State)
- No dependency on Flutter state management libraries

## Installation

Import the package in your project:

```dart
import 'package:flutter_reactive/flutter_reactive.dart';
```

---

> **Recommendation:** Prefix all reactive variable names with a lowercase `r` to make them instantly recognizable in your codebase.

```dart
// ✅ Recommended
final rCounter = Reactive(0);
final rUser = ReactiveN<UserModel>();
final rItems = <String>[].reactive();

// ❌ Possible but less clear — hard to tell at a glance which variables are reactive
final counter = Reactive(0);
final user = ReactiveN<UserModel>();
final items = <String>[].reactive();
```

## Basic Usage

Create a reactive value:

```dart
final rCounter = Reactive(0); // strict by default
final rUser = ReactiveN<UserModel>(); // nullable
final rCounterNotStrict = Reactive(0, false); // not strict, allows same value updates
final rCounterByExt = 0.reactive(); // extension helper (strict by default)
final rCounterByExtNotStrict = 0.reactive(false); // extension helper (not strict)

```

or inside a State:

```dart
class _MyState extends State<MyWidget> {
    late final rCounter = react(0); // automatically binds to this State. Needs to be late.
    late final rUser = reactN<UserModel>(); // nullable type
    late final rCounterNotStrict = react(0, false); // not strict, allows same value updates
}
```

Read & write:

```dart
rCounter.value;      // get
rCounter.value = 1;  // set
rCounter.set(2);     // explicit

rCounter.setAsync(getCounterFromDb()); // will update after

rUser.set(UserModel(...)); // set nullable value

rCounterNotStrict.value=1;
rCounterNotStrict.value=1; //still notifies because not strict

```

Control which values can be used.

```dart
rCounter
    .require((v) => v > 0) // any value <= 0 will be ignored
    .require((v) => v <= 10, "Counter should be under 10"); // any value over 10 throws an error

rCounter.value = 4;
rCounter.value = 0; // still 4
rCounter.value = -5; // still 4
rCounter.value = 10; // valid
rCounter.value = 11; // throws a ReactiveValidatorError

// you can catch to check what happened
rCounter.value = 10;
try{
  rCounter.increment(); // tries 11, throws
} on ReactiveValidatorError catch(e) {
  print(e.message); // "Counter should be under 10"
  print(e.value); // 11 (value that failed validation)
}

// To ensure all validators are applied, it's recommended to use `require` when declaring the reactive.
final rName = Reactive("").require((n)=> n.trim() != ""); // initialValue does not count

```

Update based on current value:

```dart
rCounter.update((v) => v + 1);
rUser.mutate((u) => u?.name = 'New Name'); // update and notify
```

Difference between `set`, `update` and `mutate`:

- `set(newValue)`: sets a new value and notifies listeners.
- `update((current) => newValue)`: computes a new value based on the current one and notifies listeners only if the new value is different from the current one (ex: changing user name but keeping the same UserModel instance).
- `mutate((current) => void)`: allows mutating the current value in place (useful for mutable objects). Always notifies listeners after mutation.

See the [bests practices](#tips-and-best-practices) section for more details.

## Binding a Reactive to a State

Bind a Reactive to a State so the UI updates automatically.

```dart

final rCounter = Reactive(0);// outside the State class
class _MyState extends State<MyWidget> {

    // or inside the State class
    // final rCounter = Reactive(0);

  @override
  void initState() {
    super.initState();
    rCounter.bind(this);
  }

  @override
  void dispose() {
    rCounter.unbind(this); // not strictly necessary, but cleaner
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(rCounter.value.toString());
  }
}
```

or using directly the react() method of the state:

```dart
class _MyState extends State<MyWidget> {
  late final rCounter = react(0); // automatically binds to this State. Needs to be late and inside the State class.

  @override
  Widget build(BuildContext context) {
    return Text(rCounter.value.toString());
  }
}
```

When rCounter.value changes, setState() is triggered internally.

## Unbinding

You can manually unbind a state:

```dart
rCounter.unbind(this);
```

Note: Unmounted states are automatically cleaned up internally.

## Listening without UI binding

Listen to value changes without binding to a State.

```dart
rCounter.listen((value) {
  print('Counter changed to $value');
});
```

Remove the listener:

```dart
rCounter.unlisten(myCallback);
```

## Saving and Restoring values

- A reactive can be saved and be restored later.

```dart
final rLoading = false.reactive();

rLoading.save(); // keep `false` value
rLoading.value = true; // or rLoading.enable();
// ..some actions
rLoading.restore(); // back to `false`
```

- The value can also be saved with a specific save id and be restored later with the same id. The default id is `'default'`.

```dart
final rName = ''.reactive();

rName.value = 'Andy';
rName.save('save1'); // save1 -> Andy


rName.value = 'Max';
rName.save('save2'); // save2 -> Max

rName.restore('save1'); // value is now Andy
rName.restore('save2'); // value is now Max

// Overwrite a saved value
rName.value = 'Hello world';
rName.save('save2'); // save2 -> Hello world
```

- Overwrite a saved value

```dart
// ... same rName as before
rName.value = 'Hello world';
rName.save('save2'); // save2 -> Hello world
```

- Erase a saved value

```dart
// ... same rName as before
rName.unsave('save1'); // save1 erased
rName.unsave('save2'); // save2 erased

// Or just erase all of them
rName.unsaveAll(); // default, save1 and save2 erased

rName.restore('save1'); // no effect cause no saved value
```

## Conditional reaction with `when`

Trigger a side effect only when a condition is true.

```dart
final rCounter = 0.reactive();

rCounter.when((v) => v == 0, (_) {
  print("Counter is zero");
});

rCounter.value = 1; // nothing
rCounter.value = 0; // prints "Counter is zero"
```

## Using Streams

Reactive variables expose a broadcast stream:

```dart
rCounter.stream.listen((value) {
    print("New value: $value");
});

// Difference between listen() and stream.listen():
rCounter.listen((value) {
    print("Listener: $value");
});

rCounter.value++;
// triggers both stream listener and listen() callback but stream can be used inside a StreamBuilder

StreamBuilder<int>(
    stream: rCounter.stream,
    builder: (context, snapshot) {
        return Text('Counter: ${snapshot.data}');
    },
);
```

## Using debounce and throttle with Reactive

You can debounce updates to avoid too many notifications in a short time.Also useful for search inputs and forms.

```dart
final rCounter = Reactive(0);
rCounter.debounce(Duration(seconds: 3).inMilliseconds, (value) {
  print("Counter $value");
});
```

Similar to debounce, but in throttle way.

```dart
rCounter.throttle(3000, (value) {
  print("Counter $value");
});
```

## Combine many Reactives

You can combine multiple Reactive\<T> into one Reactive\<R>.

```dart
final rA = Reactive(1);
final rB = Reactive(2);
final rSum = Reactive.combine([rA, rB], (values) => values[0] + values[1]);
// or rSum = Reactive.combine2(rA, rB, (aVal, bVal) => aVal + bVal);
rSum.listen((value) {
    print('Sum changed to $value');
});
rA.value = 3; // rSum updates to 5
rB.value = 4; // rSum updates to 7

final rActive = true.reactive();
final rCount = 0.reactive();
final rMessage = ''.reactive();
final rStatus = Reactive.combine3(
    rActive, rCount, rMessage,
    (isActive, cnt, msg) {
        return 'Status: ${isActive ? "Active" : "Inactive"}, Count: $cnt, Message: $msg';
    },
);
rStatus.listen((value) {
    print(value);
});

rActive.disable(); // prints: Status: Inactive, Count: 0, Message:
rCount.value = 10; // prints: Status: Inactive, Count: 10, Message:
rMessage.value = 'Hello'; // prints: Status: Inactive, Count: 10, Message: Hello
rActive.toggle(); // prints: Status: Active, Count: 10, Message: Hello
```

There are combine methods for up to 5 Reactives (combine2, combine3, combine4, combine5).\
For more, use combine() with a list.

If no combination function is required, use `Reactive.computed()`:

```dart
final rA = Reactive(1);
final rB = Reactive(2);
final rIsVisible = Reactive(true);
final rCombined = Reactive.computed([rA, rB, rIsVisible]); // no function needed, just tracks changes
rCombined.listen((values) {
    print('Values changed: $values');
});
```

## Reactive based on another one

You can create a reactive that depends on another one. Similar to `combine` or `compute` but for one value.

```dart
final rText = Reactive("");
final rLength = rText.as((t)=>t.length); // changes when rText changes

```

## Transactions

Use transactions to batch updates and optionally rollback on error.

```dart
final rCounter = 0.reactive().require(
  (v) => v >= 0,
  "Counter cannot be negative",
);

Reactive.run(() {
  rCounter.inc(5);
  rCounter.dec(2);
});

print(rCounter.value); // 3
```

Rollback is enabled by default:

```dart
final rCounter = 0.reactive().require(
  (v) => v >= 0,
  "Counter cannot be negative",
);

Reactive.run(
  () {
    rCounter.inc(5);
    rCounter.dec(10); // throws, full transaction is rolled back
  },
  onError: (error) => print(error),
);

print(rCounter.value); // 0
```

Manual rollback is also possible:

```dart
final rCounter = 0.reactive().require(
  (v) => v >= 0,
  "Counter cannot be negative",
);

final transaction = await Reactive.run(
  () {
    rCounter.inc(5);
    rCounter.dec(2);
  },
  rollbackOnError: false, // ensure no rollback on error, we will do it manually
);

print(rCounter.value); // 3
transaction.rollback();
print(rCounter.value); // 0
```

## Dispose the Reactive

If you want to clean up all bindings and listeners:

```dart
rCounter.dispose();
```

This will unbind all States, remove all listeners and close the stream.

## How it works

- Reactive\<T> stores a value
- Keeps a list of bound States and listeners
- On update:
  - unmounted states are removed
  - active states are updated
  - listeners are notified
- Each update also emits a value to the broadcast `stream`

Simple, explicit, predictable.

## Extensions

This package exposes extensions on:

- State (updateState, react(), reactN())
- num
- bool
- List
- String
- Map

Example:

```dart
final rIsVisible = true.reactive();
final rCount = 0.reactive();
final rItems = <String>[].reactive();

rIsVisible.toggle(); // flips the boolean
rCount.increment(); // adds 1
rCount.decrement(); // subtracts 1
rItems.addToSet('item'); // adds if not present
rItems.remove('item'); // removes if present
rItems.sort(); // sorts and notifies listeners
```

## Reactive API

Constructor:

```dart
Reactive(T initialValue, [bool strict = true])
ReactiveN<T>([T? initialValue, bool strict = true]) // nullable
T.reactive([bool strict = true]) // extension helper
```

Properties:

- `value`
- `stream`

Methods:

- `set(T newValue)`
- `setAsync(Future<T> futureValue)`
- `update(T Function(T current))`
- `mutate(void Function(T) mutator)`
- `bind(State state)`
- `unbind(State state)`
- `listen(void Function(T) callback)`
- `unlisten(void Function(T) callback)`
- `debounce(int milliseconds, void Function(T) callback)`
- `throttle(int milliseconds, void Function(T) callback)`
- `when(bool Function(T value) condition, void Function(T value) action)`
- `require(bool Function(T v) validator, [String? message])`
- `save([String id = 'default'])`
- `restore([String id = 'default'])`
- `unsave([String id = 'default'])`
- `unsaveAll()`
- `notify()`
- `dispose()`
- `as(R Function(T))`
- (For Reactive List) `sort([int Function(T a, T b)? compare])`
- (For Reactive List) `transform({ bool Function(T)? filter,  Comparable<dynamic> Function(T)? sortBy,  bool? sortByDesc,  bool? reverse,  bool? shuffle,  int? take,})`

Static Methods:

- `combine(List<Reactive> reactives, R Function(List<dynamic>) combiner)`
- `combine2`, `combine3`, `combine4`, `combine5`
- `computed(List<Reactive> reactives, [R Function(List<dynamic>)? combiner])`
- `run(FutureOr<void> Function() block, { bool rollbackOnError = true, void Function(Object error)? onError })`

### Migration Notes (0.1.0)

- `Validator` was renamed to `ReactiveValidator`
- `ValidatorError` was renamed to `ReactiveValidatorError`

Widgets:

- `ReactiveBuilder<T>` or `build(Widget Function(T))` method
- `ReactiveStreamBuilder<T>`
- `ReactiveStateBuilder`

```dart
final rCounter = 0.reactive();
ReactiveBuilder(
    reactive: rCounter,
    builder: (value) => Text('Counter: $value'),
);
rCounter.build((value) => Text('Counter: $value'));
```

- `ReactiveStreamBuilder<T>`

```dart
ReactiveStreamBuilder(
    reactive: rCounter,
    builder: (context, snapshot) {
      if(!snapshot.hasData) {
        return CircularProgressIndicator();
      }
      return Text('Counter: ${snapshot.data}');
    },
);
```

- `ReactiveStateBuilder` for multiple states in one builder

```dart

```

### Difference between ReactiveBuilder and ReactiveStreamBuilder

- `ReactiveBuilder` rebuilds when the Reactive value changes, using internal binding to State.
- `ReactiveStreamBuilder` rebuilds based on the Reactive's stream, useful for integrating with other stream-based widgets. Therefore, no internal State binding is done and you can access to the snapshot.

## Tips and Best Practices

- Avoid in-place mutations without notify():

```dart
final rUser = ReactiveN<UserModel>();
rUser.value = rUser.value.copyWith(name: "Max") // correct
rUser.mutate((u) { u?.name = "Max"; }) // correct

rUser.value.name = "Max" // incorrect, change is done but needs manually notify()
rUser.update((u) { u?.name = "Max"; return u; }) // incorrect, change is done but will not notify cause same instance and isStrict = true
```

- Use isStrict = false if you want to allow same value updates:

```dart
final rUser = ReactiveN<UserModel>(null, false); // not strict
rUser.update((u) {
    u?.name = "Max";
    return u; // will notify even if same instance
});
```

- Use `debounce()` for search inputs or frequent updates:

```dart
final rSearchQuery = ''.reactive();

rSearchQuery.listen((value) {
  search(value);  // ❌ Bad practice: this will trigger on every keystroke
});
rSearchQuery.debounce(500, (value) {
  search(value);  // ✅ Good practice: this will trigger only after 500ms of inactivity
});
```

- Use `combine()` or `computed()` to track multiple Reactives:

```dart
final rA = Reactive(1);
final rB = Reactive(2);

// ❌ BAD
final rSum = Reactive(0);
rA.listen((aVal) {
    rSum.value = aVal + rB.value;
});
rB.listen((bVal) {
    rSum.value = rA.value + bVal;
});

// ✅ GOOD
final rSum = Reactive.combine2(rA, rB, (aVal, bVal) => aVal + bVal);
//or int get sum => rA.value + rB.value;
final rCombined = Reactive.computed([rA, rB], ()=> rA.value + rB.value);
```

- Don't manually change combined or computed Reactives:

Combined or computed Reactives should not be set manually as they derive their value from other Reactives. Because it is possible do not mean to do it, avoid it to prevent confusion and unpredictable behavior.

```dart
final rA = Reactive(1);
final rB = Reactive(2);
final rSum = Reactive.combine2(rA, rB, (aVal, bVal) => aVal + bVal);
rSum.value = 10; // ❌ BAD: rSum is computed, don't set it manually
```

- Limit excessive rebuilds:

Using `react()` or `Reactive<T>`.bind() inside a State class is the most common use case but should be used wisely cause each change triggers a setState().\
If you have many Reactive values changing frequently, or all your state does not depend on them, consider using `Reactive<T>` + `ReactiveBuilder` or `ReactiveStreamBuilder` to limit rebuilds to only the widgets that need them.\
Here are some examples:

```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}
class _CounterWidgetState extends State<CounterWidget> {
  late final rCounter = react(0); // binds to this State
  late final rCounterNotBound = Reactive(0); // can be outside the State class

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $rCounter'), //the state rebuilds on rCounter change
        ReactiveBuilder(
          reactive: rCounterNotBound, // only this widget rebuilds on rCounterNotBound change
          builder: (value) => Text('Counter: $value'),
        ),
        ElevatedButton(
          onPressed: () => rCounter.increment(), // excessive rebuilds
          child: Text('Increment'),
        ),
        ElevatedButton(
          onPressed: () => rCounterNotBound.increment(), // only rebuilds ReactiveBuilder
          child: Text('Increment Not Bound'),
        ),
      ],
    );
  }
}
```

### Recommended Architecture

For larger applications, consider separating your state management from your UI components. Use Reactive variables in your store or controller classes, and bind them to your UI using `ReactiveBuilder` or `ReactiveStreamBuilder`. This approach promotes a cleaner architecture and better separation of concerns.

```dart
// lib/services/auth_service.dart
import 'package:flutter_reactive/flutter_reactive.dart';
class AuthService {
  static final rUser = ReactiveN<UserModel>(); // static so can be used globally if needed

  static bool get isLoggedIn => rUser.value != null;

  static void login(UserModel newUser) {
    rUser.value = newUser;
  }

  static void logout() {
    rUser.value = null;
  }
}
```

```dart
// lib/stores/form_store.dart
import 'package:flutter_reactive/flutter_reactive.dart';
class FormStore {
  final rUsername = ''.reactive(); // or Reactive("");
  final rPassword = ''.reactive();

  final rIsValid = Reactive.combine2(
    rUsername,
    rPassword,
    (u, p) => u.isNotEmpty && p.isNotEmpty && p.length >= 6,
  );


  void updateUsername(String value) {
    rUsername.value = value;
  }

  void updatePassword(String value) {
    rPassword.value = value;
  }

  Future<void> save() async {
    if(rIsValid.isTrue){
      final json = await db.login(rUsername.value, rPassword.value);
      AuthService.login(UserModel.fromJson(json)); // save user globally
    }
  }

}
```

```dart
// lib/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';
import '../stores/form_store.dart';
class LoginForm extends StatelessWidget {
  final FormStore store = FormStore();

  void initState() {
    AuthService.rUser.bind(this); // bind to AuthService rUser to update UI on login/logout
  }

  @override
  Widget build(BuildContext context) {
    return AuthService.isLoggedIn
      ? Column(
          children: [
            Text('Welcome, ${AuthService.rUser.value?.name}!'),
            ElevatedButton(
              onPressed: () => AuthService.logout(),
              child: Text('Logout'),
            ),
          ],
        )
      : Column(
          children: [
            TextField(
              onChanged: store.updateUsername,
              decoration: InputDecoration(labelText: 'Username'),
            ),
        TextField(
          onChanged: store.updatePassword,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        ReactiveBuilder(
          reactive: store.rIsValid,
          builder: (isValid) {
            return ElevatedButton(
              onPressed: isValid ? store.save : null,
              child: Text('Login'),
            );
          },
        ),
      ],
    );
  }
}
```

In this example, the `AuthService` manages the global user state, while the `FormStore` handles the login form state. The `LoginForm` widget binds to the `AuthService` to update the UI based on the authentication state.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
Do whatever you want but don't blame the me ;).
