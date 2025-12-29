import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

/// A widget that rebuilds whenever a [Reactive<T>] value changes.
///
/// Provides the current value directly to the builder without passing BuildContext.
class ReactiveBuilder<T> extends StatefulWidget {
  const ReactiveBuilder({
    super.key,
    required this.reactive,
    required this.builder,
  });

  /// The reactive value to listen to.
  final Reactive<T> reactive;

  /// Builder function that receives only the current value.
  final Widget Function(T value) builder;

  @override
  State<ReactiveBuilder<T>> createState() => _ReactiveBuilderState<T>();
}

class _ReactiveBuilderState<T> extends State<ReactiveBuilder<T>> {
  @override
  void initState() {
    super.initState();
    widget.reactive.bind(this);
  }

  @override
  void didUpdateWidget(covariant ReactiveBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reactive != widget.reactive) {
      oldWidget.reactive.unbind(this);
      widget.reactive.bind(this);
    }
  }

  @override
  void dispose() {
    widget.reactive.unbind(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(widget.reactive.value);
  }
}
