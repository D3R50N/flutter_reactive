# Flutter Reactive

Flutter Reactive is a lightweight reactive state package for Flutter.
It gives you local widget state, shared stores, derived values, and automatic rebuilds — without code generation or extra boilerplate.

<p align="center">
  <img src="logo.svg" width="280" alt="Flutter Reactive logo" />
</p>

## Documentation

- Official docs: <https://flutterreactive.com>
- Docs source: [doc/](doc/)
- Source and examples: [example/](example/)

## Features

- Observable values with `Reactive<T>` and `ReactiveN<T>`
- Local widget state with `react()` and `reactN()`
- Automatic rebuilds with `ReactiveBuilder` and `ReactiveStateBuilder`
- Shared stores with `ReactiveDependency` and `RxDep`
- Derived values with `as`, `compute`, and `combine`
- Transactions, validators, save/restore checkpoints, and stream listeners
- Helper extensions for numbers, booleans, strings, iterables, lists, and maps

## Installation

```bash
dart pub add flutter_reactive
```

```dart
import 'package:flutter_reactive/flutter_reactive.dart';
```

## Quick Start

```dart
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  late final counter = react(0);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Counter: ${counter.value}'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: counter.increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

`react()` creates a `Reactive<T>` and binds it to the current `State`, so updates trigger `setState()` automatically.

## Widget Binding

Use `ReactiveBuilder` when you want a widget to rebuild from reactive reads:

```dart
ReactiveBuilder(() {
  return Text('Counter: ${counter.value}');
});
```

Or watch a specific reactive explicitly:

```dart
ReactiveBuilder.watch(counter, (value) {
  return Text('Counter: $value');
});
```

`ReactiveBuilder.stream(...)` is also available when you prefer Flutter's `StreamBuilder` API.

For local widget state machines, use `ReactiveStateBuilder`:

```dart
ReactiveStateBuilder<bool>(
  initialState: false,
  states: {
    false: (state) => ElevatedButton(
      onPressed: state.enable,
      child: const Text('Open'),
    ),
    true: (state) => ElevatedButton(
      onPressed: state.disable,
      child: const Text('Close'),
    ),
  },
);
```

## Derived State

```dart
final price = 100.rx;
final quantity = 2.rx;

final total = compute(() => price.value * quantity.value);
final label = total.as((value) => 'Total: \$${value.toStringAsFixed(0)}');

final summary = combine2(
  price,
  quantity,
  (p, q) => '$q × \$${p.toStringAsFixed(0)}',
);
```

`compute`, `combine`, and the typed helpers (`combine2` to `combine5`) return read-only reactives. Trying to set a value on them throws a state error.

Values can be accessed via `.value`, `.v`, or by calling the instance directly `counter()`.


## Side Effects

```dart
final counter = 0.rx;

final sub = counter.listen((value) {
  debugPrint('Counter changed: $value');
}, true);

sub.cancel(); // Unsubscribe when no longer needed

counter.once((value) {
  debugPrint('First value: $value');
});

counter.when((value) => value == 10, (value) {
  debugPrint('Reached $value');
});
```

`listen` works independently from the widget tree. It is useful for logging, syncing, analytics, or imperative side effects.

## Shared Dependencies

```dart
class UserStore extends ReactiveDependency {
  final name = 'Alice'.rx;

  void rename(String value) => name.value = value;
}

final store = UserStore().dep;
store.rename('Bob');
store.dispose();
```

`dep` registers a single instance per type, which makes it convenient for shared stores and service-like objects.

## Mutable Models

```dart
class User {
  User(this.name, this.age);

  String name;
  int age;
}

final user = User('Alice', 30).rx
    .require((value) => value.age >= 0, 'Age cannot be negative')
    .require((value) => value.name.trim().isNotEmpty, 'Name cannot be empty');

user.mutate((value) {
  value.name = 'Bob';
  value.age = 31;
});
```

Use `mutate` when you intentionally update an object in place. For immutable updates, prefer assigning a new value instead.

## Transactions, Validation, and Checkpoints

```dart
final stock = <String, int>{'Latte': 3}.rx;
final sold = <String>[].rxNonStrict;

await rxRun(() {
  stock.put('Latte', stock.get('Latte')! - 2);
  sold.add('ticket-1');
});
```

If an error is thrown, changes are rolled back by default. You can also disable automatic rollback and handle it manually through the returned transaction.

Save and restore checkpoints when you want lightweight state snapshots:

```dart
final counter = 0.rx;

counter.save('draft');
counter.increment(5);
counter.restore('draft');
```

## Collection And Primitive Helpers

`flutter_reactive.dart` exports helpers for common reactive data types:

- `num`: `increment`, `decrement`, `inc`, `dec`, `clamp`, `roundTo`
- `bool`: `toggle`, `enable`, `disable`
- `String`: `trim`, `append`, `prepend`, `toUpper`, `toLower`
- `Iterable` / `List`: `add`, `addFirst`, `addAll`, `remove`, `sort`, `transform`, `at`, `atOrNull`
- `Map`: `put`, `remove`, `get`, `has`

A quick example:

```dart
final name = ' Flutter '.rx;
name.trim();
name.toUpper();
name.append(' Reactive');

final items = <int>[2, 5, 1].rxNonStrict;
items.addFirst(9);
items.sort();

final settings = <String, dynamic>{}.rx;
settings.put('theme', 'dark');
```

## Best Practices

- Prefer immutable updates whenever possible.
- Use `rxNonStrict` for mutable collections or repeated equal values that should still notify listeners.
- Use `mutate` only when in-place mutation is intentional.
- Dispose long-lived reactives or shared stores when they are no longer needed.

## License

MIT. See [LICENSE](LICENSE).

## Example

See [`example/`](example/) for a complete Flutter sample app.
