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
final counter = Reactive<int>(0);
```

or inside a State:

```dart
class _MyState extends State<MyWidget> {
    late final counter = react(0); // automatically binds to this State. Needs to be late.
}
```

Read & write:

```dart
counter.value;      // get
counter.value = 1;  // set
counter.set(2);     // explicit
```

Update based on current value:

```dart
counter.update((v) => v + 1);
```

See the [bests practices](#tips-and-best-practices) section for more details.

## Binding a Reactive to a State

Bind a Reactive to a State so the UI updates automatically.

```dart

final counter = Reactive<int>(0);// outside the State class
class _MyState extends State<MyWidget> {

    // or inside the State class
    // final counter = Reactive<int>(0);

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

## Combine many Reactives

You can combine multiple Reactive\<T> into one Reactive\<R>.

```dart
final a = Reactive<int>(1);
final b = Reactive<int>(2);
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

- State (updateState, react())
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
```

Properties:

- value
- stream

Methods:

- set(T newValue)
- update(T Function(T current))
- bind(State state)
- unbind(State state)
- listen(void Function(T) callback)
- unlisten(void Function(T) callback)
- notify()
- dispose()

Widgets:

- ReactiveBuilder\<T>

```dart
final counter= 0.reactive();
ReactiveBuilder(
    reactive: counter,
    builder: (value) => Text('Counter: $value'),
);
```

- ReactiveStreamBuilder\<T>

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

- ReactiveBuilder rebuilds when the Reactive value changes, using internal binding to State.
- ReactiveStreamBuilder rebuilds based on the Reactive's stream, useful for integrating with other stream-based widgets. Therefore, no internal State binding is done and you can access to the snapshot.

## Tips and Best Practices

Using `react()` or `Reactive\<T>`.bind() inside a State class is the most common use case but should be used wisely cause each change triggers a setState().\
If you have many Reactive values changing frequently, or all your state does not depend on them, consider using `Reactive\<T>` + `ReactiveBuilder` or `ReactiveStreamBuilder` to limit rebuilds to only the widgets that need them.\
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
        Text('Counter: $value'), //the state rebuilds on counter change
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

MIT — do whatever you want, just don’t blame the code
