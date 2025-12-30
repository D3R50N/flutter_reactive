import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension on Flutter's [State] to simplify Reactive usage.
extension ReactiveState on State {
  /// Calls [setState] safely only if the state is mounted.
  ///
  /// Optionally, you can provide a [callback] to update local variables.
  ///
  /// Example:
  /// ```dart
  /// class _MyWidgetState extends State<MyWidget> {
  ///   int counter = 0;
  ///
  ///   void increment() {
  ///     updateState(() {
  ///       counter++;
  ///     });
  ///   }
  /// }
  /// ```
  void updateState([VoidCallback? callback]) {
    if (mounted) setState(callback ?? () {});
  }

  /// Creates a [Reactive] variable and binds it automatically to this state.
  ///
  /// This allows the reactive value to trigger `setState` automatically
  /// whenever it changes.
  ///
  /// Example:
  /// ```dart
  /// late final counter = react(0);
  ///
  /// ElevatedButton(
  ///   onPressed: () => counter.value++,
  ///   child: Text('${counter.value}'),
  /// );
  /// ```
  Reactive<T> react<T>(T initial, [bool strict = true]) {
    final r = Reactive<T>(initial, strict);
    r.bind(this);
    return r;
  }

  ReactiveN<T> reactN<T>([T? initial, bool strict = true]) {
    final r = ReactiveN<T>(initial, strict);
    r.bind(this);
    return r;
  }
}
