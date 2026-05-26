import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

/// A widget that rebuilds automatically from any reactive values read
/// inside its [builder].
class ReactiveBuilder extends StatefulWidget {
  const ReactiveBuilder(this.builder, {super.key});

  /// Builder function whose reactive reads are tracked automatically.
  final Widget Function() builder;

  /// Build a widget from a specific [reactive] value.
  static Widget watch<T>(
    Reactive<T> reactive,
    Widget Function(T value) builder, {
    Key? key,
  }) {
    return _ReactiveValueBuilder<T>(
      key: key,
      reactive: reactive,
      builder: builder,
    );
  }

  /// Builds a [StreamBuilder] wired to the [reactive] stream.
  ///
  /// This is useful when you want direct access to the [AsyncSnapshot]
  /// produced by Flutter's stream widgets.
  ///
  /// When [withInitial] is true, the current [reactive] value is
  /// passed to `StreamBuilder.initialData`.
  static Widget stream<T>(
    Reactive<T> reactive,
    AsyncWidgetBuilder<T> builder, {
    Key? key,
    bool withInitial = true,
  }) {
    return StreamBuilder<T>(
      key: key,
      stream: reactive.stream,
      initialData: withInitial ? reactive.value : null,
      builder: builder,
    );
  }

  /// Build a widget from two explicit reactive values.
  static Widget watch2<A, B>(
    Reactive<A> a,
    Reactive<B> b,
    Widget Function(A a, B b) builder, {
    Key? key,
  }) {
    return ReactiveBuilder(() => builder(a.value, b.value), key: key);
  }

  /// Build a widget from three explicit reactive values.
  static Widget watch3<A, B, C>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    Widget Function(A a, B b, C c) builder, {
    Key? key,
  }) {
    return ReactiveBuilder(() => builder(a.value, b.value, c.value), key: key);
  }

  /// Build a widget from four explicit reactive values.
  static Widget watch4<A, B, C, D>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    Reactive<D> d,
    Widget Function(A a, B b, C c, D d) builder, {
    Key? key,
  }) {
    return ReactiveBuilder(
      () => builder(a.value, b.value, c.value, d.value),
      key: key,
    );
  }

  /// Build a widget from five explicit reactive values.
  static Widget watch5<A, B, C, D, E>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    Reactive<D> d,
    Reactive<E> e,
    Widget Function(A a, B b, C c, D d, E e) builder, {
    Key? key,
  }) {
    return ReactiveBuilder(
      () => builder(a.value, b.value, c.value, d.value, e.value),
      key: key,
    );
  }

  @override
  State<ReactiveBuilder> createState() => _ReactiveBuilderState();
}

class _ReactiveBuilderState extends State<ReactiveBuilder> {
  late Reactive<Widget> _computed;

  @override
  void initState() {
    super.initState();
    _computed = Reactive.compute(widget.builder);
    _computed.bind(this);
  }

  @override
  void didUpdateWidget(covariant ReactiveBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.builder != widget.builder) {
      _computed.unbind(this);
      _computed.dispose();
      _computed = Reactive.compute(widget.builder);
      _computed.bind(this);
    }
  }

  @override
  void dispose() {
    _computed.unbind(this);
    _computed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _computed.value;
  }
}

class _ReactiveValueBuilder<T> extends StatefulWidget {
  const _ReactiveValueBuilder({
    super.key,
    required this.reactive,
    required this.builder,
  });

  final Reactive<T> reactive;
  final Widget Function(T value) builder;

  @override
  State<_ReactiveValueBuilder<T>> createState() =>
      _ReactiveValueBuilderState<T>();
}

class _ReactiveValueBuilderState<T> extends State<_ReactiveValueBuilder<T>> {
  @override
  void initState() {
    super.initState();
    widget.reactive.bind(this);
  }

  @override
  void didUpdateWidget(covariant _ReactiveValueBuilder<T> oldWidget) {
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

/// Shorthand alias for [ReactiveBuilder].
typedef Rxb = ReactiveBuilder;
