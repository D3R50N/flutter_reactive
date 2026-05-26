part of 'flutter_reactive.dart';

/// A nullable variant of [Reactive].
///
/// This is a convenience wrapper around `Reactive<T?>` for values that may be
/// absent.
class ReactiveN<T> extends Reactive<T?> {
  /// Creates a nullable reactive with an optional initial value.
  ReactiveN([super._value, super._strict]);
}
