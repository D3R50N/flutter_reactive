import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

/// A convenience widget that rebuilds itself whenever a [Reactive<T>] value changes.
///
/// This widget wraps a [Reactive<T>] in a [StreamBuilder], using the reactive's
/// internal broadcast stream. It automatically provides the current value as
/// `initialData`, so the builder always has an initial snapshot.
///
/// Example:
/// ```dart
/// final counter = Reactive<int>(0);
///
/// ReactiveStreamBuilder<int>(
///   reactive: counter,
///   builder: (context, snapshot) {
///     return Text('Value: ${snapshot.data}');
///   },
/// );
///
/// counter.value++;
/// ```
class ReactiveStreamBuilder<T> extends StatelessWidget {
  /// Creates a [ReactiveStreamBuilder] that listens to a [Reactive] stream.
  const ReactiveStreamBuilder({
    super.key,
    required this.reactive,
    required this.builder,
  });

  /// The reactive value to listen to.
  final Reactive<T> reactive;

  /// Builder function that receives the [BuildContext] and [AsyncSnapshot] of the reactive value.
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: reactive.stream,
      initialData:
          reactive.value, // ensures snapshot has current value initially
      builder: builder,
    );
  }
}
