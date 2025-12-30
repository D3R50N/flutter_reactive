# Flutter Reactive

A lightweight reactive system for Flutter, inspired by simple state binding.
No ChangeNotifier, no boilerplate — just Reactive values bound to States and optional streams.

## Features

- Reactive variables (Reactive\<T>)
- Automatic State updates when data changes
- Manual listeners support
- Reactive streams support (`stream`)
- Extensions on common types (num, bool, List, String, Map, State)
- No dependency on Flutter state management libraries

## Installation

Import the package in your project:

```dart
import 'package:flutter_reactive/flutter_reactive.dart';
```

## Basic Usage

Create a reactive value:

```dart
final counter = Reactive(0); // strict by default
final user = ReactiveN<UserModel>(); // nullable
final counterNotStrict = Reactive(0, false); // not strict, allows same value updates

```

or inside a State:

```dart
class _MyState extends State<MyWidget> {
    late final counter = react(0); // automatically binds to this State. Needs to be late.
    late final user = reactN<UserModel>(); // nullable type
    late final counterNotStrict = react(0, false); // not strict, allows same value updates
}
```

Read & write:

```dart
counter.value;      // get
counter.value = 1;  // set
counter.set(2);     // explicit

user.set(UserModel(...)); // set nullable value

counterNotStrict.value=1;
counterNotStrict.value=1; //still notifies because not strict

```

Update based on current value:

```dart
counter.update((v) => v + 1);
user.mutate((u) => u?.name = 'New Name'); // update and notify
```

Difference between `set`, `update` and `mutate`:

- `set(newValue)`: sets a new value and notifies listeners.
- `update((current) => newValue)`: computes a new value based on the current one and notifies listeners only if the new value is different from the current one (ex: changing user name but keeping the same UserModel instance).
- `mutate((current) => void)`: allows mutating the current value in place (useful for mutable objects). Always notifies listeners after mutation.

See the [bests practices](#tips-and-best-practices) section for more details.

## Binding a Reactive to a State

Bind a Reactive to a State so the UI updates automatically.

```dart

final counter = Reactive(0);// outside the State class
class _MyState extends State<MyWidget> {

    // or inside the State class
    // final counter = Reactive(0);

  @override
  void initState() {
    super.initState();
    counter.bind(this);
  }

  @override
  void dispose() {
    counter.unbind(this); // not strictly necessary, but cleaner
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(counter.value.toString());
  }
}
```

or using the react() helper:

```dart
class _MyState extends State<MyWidget> {
  late final counter = react(0); // automatically binds to this State. Needs to be late and inside the State class.

  @override
  Widget build(BuildContext context) {
    return Text(counter.value.toString());
  }
}
```

When counter.value changes, setState() is triggered internally.

## Unbinding

You can manually unbind a state:

```dart
counter.unbind(this);
```

Note: Unmounted states are automatically cleaned up internally.

## Listening without UI binding

Listen to value changes without binding to a State.

```dart
counter.listen((value) {
  print('Counter changed to $value');
});
```

Remove the listener:

```dart
counter.unlisten(myCallback);
```

## Using Streams

Reactive variables expose a broadcast stream:

```dart
counter.stream.listen((value) {
    print("New value: $value");
});

// Difference between listen() and stream.listen():
counter.listen((value) {
    print("Listener: $value");
});

counter.value++;
// triggers both stream listener and listen() callback but stream can be used inside a StreamBuilder

StreamBuilder<int>(
    stream: counter.stream,
    builder: (context, snapshot) {
        return Text('Counter: ${snapshot.data}');
    },
);
```

## Using debounce with Reactive

You can debounce updates to avoid too many notifications in a short time.Also useful for search inputs and forms.

```dart
final counter = Reactive(0);
counter.debounce(Duration(seconds: 3).inMilliseconds, (value) {
  print("Counter $value");
});
```

## Combine many Reactives

You can combine multiple Reactive\<T> into one Reactive\<R>.

```dart
final a = Reactive(1);
final b = Reactive(2);
final sum = Reactive.combine([a, b], (values) => values[0] + values[1]);
// or sum = Reactive.combine2(a, b, (aVal, bVal) => aVal + bVal);
sum.listen((value) {
    print('Sum changed to $value');
});
a.value = 3; // sum updates to 5
b.value = 4; // sum updates to 7

final active=true.reactive();
final count=0.reactive();
final message=''.reactive();
final status = Reactive.combine3(
    active, count, message,
    (isActive, cnt, msg) {
        return 'Status: ${isActive ? "Active" : "Inactive"}, Count: $cnt, Message: $msg';
    },
);
status.listen((value) {
    print(value);
});

active.disable(); // prints: Status: Inactive, Count: 0, Message:
count.value = 10; // prints: Status: Inactive, Count: 10, Message:
message.value = 'Hello'; // prints: Status: Inactive, Count: 10, Message: Hello
active.toggle(); // prints: Status: Active, Count: 10, Message: Hello
```

There are combine methods for up to 5 Reactives (combine2, combine3, combine4, combine5).\
For more, use combine() with a list.

If no combination function is required, use `Reactive.computed()`:

```dart
final a = Reactive(1);
final b = Reactive(2);
final isVisible = Reactive(true);
final combined = Reactive.computed([a, b, isVisible]); // no function needed, just tracks changes
combined.listen((values) {
    print('Values changed: $values');
});
```

## Dispose the Reactive

If you want to clean up all bindings and listeners:

```dart
counter.dispose();
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
final isVisible = true.reactive();
final count = 0.reactive();
final items = <String>[].reactive();

isVisible.toggle(); // flips the boolean
count.increment(); // adds 1
count.decrement(); // subtracts 1
items.addToSet('item'); // adds if not present
items.remove('item'); // removes if present
```

## Reactive API

Constructor:

```dart
Reactive(T initialValue)
ReactiveN<T>() // nullable
Reactive(T initialValue, bool isStrict) // isStrict: prevents notifying on same value updates. Default: true 
```

Properties:

- `value`
- `stream`

Methods:

- `set(T newValue)`
- `update(T Function(T current))`
- `bind(State state)`
- `unbind(State state)`
- `listen(void Function(T) callback)`
- `unlisten(void Function(T) callback)`
- `notify()`
- `dispose()`
- `mutate(void Function(T) mutator)`
- `debounce(int milliseconds, void Function(T) callback)`

Static Methods:

- `combine(List<Reactive> reactives, R Function(List<dynamic>) combiner)`
- `combine2`, `combine3`, `combine4`, `combine5`
- `computed(List<Reactive> reactives, [R Function(List<dynamic>)? combiner])`

Widgets:

- `ReactiveBuilder<T>`

```dart
final counter= 0.reactive();
ReactiveBuilder(
    reactive: counter,
    builder: (value) => Text('Counter: $value'),
);
```

- `ReactiveStreamBuilder<T>`

```dart
ReactiveStreamBuilder(
    reactive: counter,
    builder: (context, snapshot) {
      if(!snapshot.hasData) {
        return CircularProgressIndicator();
      }
      return Text('Counter: ${snapshot.data}');
    },
);
```

### Difference between ReactiveBuilder and ReactiveStreamBuilder

- `ReactiveBuilder` rebuilds when the Reactive value changes, using internal binding to State.
- `ReactiveStreamBuilder` rebuilds based on the Reactive's stream, useful for integrating with other stream-based widgets. Therefore, no internal State binding is done and you can access to the snapshot.

## Tips and Best Practices

| DO                                                               | DON'T                                                                 | Reason                                                                                         |
| ---------------------------------------------------------------- | --------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `user.value = user.value.copyWith(name: "Max")`                  | `user.value.name = "Max"` (without user.notify())                     | Reactive does not detect in-place mutations. You must call `notify()` after in-place mutations |
| `user.mutate((u) { u.name = "Max"; })`                           | Mutate the model outside Reactive                                     | Ensures `notify()` is called                                                                   |
| `counter.update((v) => otherValue)`                              | `counter.mutate((v) { v = otherValue; })`                             | Mutate will not change the reference, so no change will be detected. Use update instead.       |
| Use `Reactive.combine` or `Reactive.computed` for derived values | Manually listen to multiple Reactives                                 | Simplifies code and ensures proper cleanup                                                     |
| `final myReactive= initialValue.reactive();`                     | `final myReactive=  initialValue.reactive().reactive().reactive()...` | Avoid chaining reactives, it's unnecessary and wasteful.                                       |
| Use `ReactiveBuilder` or `ReactiveStreamBuilder` for UI updates  | Manually bind Reactives to States for UI updates                      | Simplifies code and ensures better performance (see below)                                     |

Using `react()` or `Reactive<T>`.bind() inside a State class is the most common use case but should be used wisely cause each change triggers a setState().\
If you have many Reactive values changing frequently, or all your state does not depend on them, consider using `Reactive<T>` + `ReactiveBuilder` or `ReactiveStreamBuilder` to limit rebuilds to only the widgets that need them.\
Here are some examples:

```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}
class _CounterWidgetState extends State<CounterWidget> {
  late final counter = react(0); // binds to this State
  late final counterNotBound = Reactive(0); // can be outside the State class

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $counter'), //the state rebuilds on counter change
        ReactiveBuilder(
          reactive: counterNotBound, // only this widget rebuilds on counterNotBound change
          builder: (value) => Text('Counter: $value'),
        ),
        ElevatedButton(
          onPressed: () => counter.increment(), // excessive rebuilds
          child: Text('Increment'),
        ),
        ElevatedButton(
          onPressed: () => counterNotBound.increment(), // only rebuilds ReactiveBuilder
          child: Text('Increment Not Bound'),
        ),
      ],
    );
  }
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
Do whatever you want but don't blame the code ;).
