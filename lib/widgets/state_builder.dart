import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

/// A lightweight state-switching widget backed by an internal [Reactive].
///
/// It maps values of type [T] to widget builders through [states] and rebuilds
/// automatically whenever the internal reactive state changes.
class ReactiveStateBuilder<T> extends StatefulWidget {
  /// Creates a [ReactiveStateBuilder].
  const ReactiveStateBuilder({
    super.key,
    this.states = const {},
    required this.initialState,
    this.onInit,
  });

  /// The initial value for the internal reactive state.
  final T initialState;

  /// Called once during initialization with the internal reactive state.
  ///
  /// This is useful for wiring listeners or triggering asynchronous setup.
  final void Function(Reactive<T> reactive)? onInit;

  /// Maps each possible state value to the widget builder that should render it.
  final Map<T, Widget Function(Reactive<T> reactive)> states;

  @override
  State<ReactiveStateBuilder<T>> createState() =>
      _ReactiveStateBuilderState<T>();
}

class _ReactiveStateBuilderState<T> extends State<ReactiveStateBuilder<T>> {
  late final Reactive<T> _state = Reactive<T>(widget.initialState);

  @override
  void initState() {
    super.initState();
    widget.onInit?.call(_state);
  }

  @override
  void didUpdateWidget(covariant ReactiveStateBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialState != widget.initialState) {
      _state.value = widget.initialState;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveBuilder.watch(_state, (v) {
      final builder = widget.states[v];
      if (builder != null) {
        return builder(_state);
      }
      return const SizedBox.shrink();
    });
  }
}

/// Shorthand alias for [ReactiveStateBuilder]
typedef Rxsb = ReactiveStateBuilder;
