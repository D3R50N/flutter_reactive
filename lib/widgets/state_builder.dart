import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

class ReactiveStateBuilder<T> extends StatefulWidget {
  const ReactiveStateBuilder({
    super.key,
    this.states = const {},
    required this.initialState,
    this.onInit,
  });

  final T initialState;
  final void Function(Reactive<T> reactive)? onInit;
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
  Widget build(BuildContext context) {
    return ReactiveBuilder(reactive: _state, builder: (v) {
      final builder = widget.states[v];
      if (builder != null) {
        return builder(_state);
      }
      return const SizedBox.shrink();
    });
  }
}
