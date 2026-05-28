# Flutter Reactive

Flutter Reactive is a lightweight reactive state package for Flutter.
It gives you local and shared state, derived values, and widget bindings without codegen or external dependencies.

<img src="logo.svg" width="300" alt="Flutter Reactive logo"/>

## Installation

```bash
dart pub add flutter_reactive
```

```dart
import 'package:flutter_reactive/flutter_reactive.dart';
```

## Quick Start

```dart
final counter = Reactive(0);

counter.value = 1;
counter.set(2);
counter.update((value) => value + 1);
await counter.setAsync(Future.value(10));
```

Use the `rt` and `rtNonStrict` extensions when you want shorter syntax:

```dart
final rCount = 0.rt;
final rLoose = 0.rtNonStrict;
final rName = ReactiveN<String>();
```

## Bind To A Widget

```dart
class _MyPageState extends State<MyPage> {
  late final counter = react(0);

  @override
  Widget build(BuildContext context) {
    return Text('Counter: ${counter.value}');
  }
}
```

Or bind manually:

```dart
final counter = Reactive(0);

@override
void initState() {
  super.initState();
  counter.bind(this);
}

@override
void dispose() {
  counter.unbind(this);
  super.dispose();
}
```

## Core Features

- `listen`, `unlisten`, `stream`, and `notify`
- `ReactiveBuilder` / `Rxb` and `ReactiveStateBuilder` / `Rxsb`
- Shared dependencies with `ReactiveDependency` and `RxDep`
- Validation with `require(...)`
- Derived state with `as`, `combine`, and `compute`
- Transactions with optional rollback via `Reactive.run(...)`
- Save and restore checkpoints with `save`, `restore`, `unsave`, and `unsaveAll`
- Helpers such as `debounce`, `throttle`, `when`, `setAsync`, and `mutate`
- Extensions for `bool`, `num`, `String`, `Iterable`, `List`, `Map`, and `State`

## Listeners And Streams

```dart
void onCounterChanged(int value) {
  debugPrint('Counter changed: $value');
}

final sub = counter.listen(onCounterChanged);
counter.listen(onCounterChanged, true);
counter.unlisten(onCounterChanged); // or sub.cancel();

counter.stream.listen((value) {
  debugPrint('Stream value: $value');
});
```

## Derived State

```dart
final price = 100.rt;
final qty = 2.rt;

final total = Reactive.compute(() => price.value * qty.value);
final label = price.as((value) => '\$${value.toStringAsFixed(0)}');
```

`compute` and `combine*` return read-only reactives.

## Shared Dependencies

```dart
class UserStore extends ReactiveDependency {
  final name = 'Alice'.rt;
}

final user = UserStore().dep;
final sameUser = UserStore().dep;
RxDep.drop<UserStore>();
```

## Validation

```dart
final counter = 0
    .rt
    .require((value) => value >= 0, 'Counter cannot be negative')
    .require((value) => value <= 10, 'Counter must be <= 10');
```

## Transactions

```dart
await Reactive.run(() {
  counter.inc(5);
  counter.dec(2);
});
```

Rollback happens automatically when an error is thrown. You can also disable rollback and handle it manually with the returned transaction.

## Best Practices

- Prefer immutable updates when possible.
- Use strict mode for predictable change detection.
- Use non-strict mode when repeated equal values should still notify listeners.
- Dispose long-lived reactives when they are no longer needed.

## Breaking Changes In 1.0.0

- `ReactiveBuilder(reactive: ..., builder: ...)` is no longer the main API.
- `Reactive.computed(...)` became `Reactive.compute(...)`.
- `listen(callback, true)` emits the current value immediately.
- `extensions/list.dart` became `extensions/iterable.dart`.

## License

MIT. See [LICENSE](LICENSE).
