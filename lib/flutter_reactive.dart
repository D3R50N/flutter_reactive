library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive/extensions/state.dart';
import 'package:flutter_reactive/widgets/reactive_builder.dart';

export 'extensions/all.dart';
export 'extensions/bool.dart';
export 'extensions/iterable.dart';
export 'extensions/map.dart';
export 'extensions/num.dart';
export 'extensions/state.dart';
export 'extensions/string.dart';
export 'widgets/reactive_builder.dart';
export 'widgets/state_builder.dart';
export 'widgets/stream_builder.dart';

part 'core/base_reactive.dart';
part 'core/readonly_reactive.dart';
part 'core/transaction.dart';
part 'core/transaction_manager.dart';
part 'core/validator.dart';
part 'flutter_reactive_n.dart';

/// A lightweight reactive state holder.
///
/// `Reactive<T>` is a simple observable container that:
/// - holds a value of type [T]
/// - notifies bound Flutter [State] objects on change (via `setState`)
/// - notifies registered listeners
///
/// It is designed for **local and shared UI state** without boilerplate,
/// builders, or external dependencies.
///
/// Typical use case:
/// ```dart
/// late final counter = reactive(0);
///
/// counter.value++;
/// ```
///
/// All bound widgets will automatically rebuild.
class Reactive<T> extends BaseReactive<T> {
  /// Creates a new [Reactive] with an initial value.
  Reactive(super._value, [super.strict = true]);

  final Map<String, T> _savedStates = {};

  /// Updates the value and notifies listeners and bound states.
  set value(T newValue) => set(newValue);

  /// Sets a new value.
  ///
  /// If the reactive is read-only, it will throw an error
  /// If the value did not change, nothing happens.
  /// If the value is rejected by any validator, it is not updated and no notification occurs.
  /// If the value is updated, all bound states are rebuilt and listeners are notified.
  /// If the value is updated within a transaction, notifications are deferred until the transaction is committed.
  void set(T newValue) => _set(newValue);

  /// Sets asynchronously
  Future<void> setAsync(Future<T> futureValue) async {
    value = await futureValue;
  }

  /// Updates the value using a transformation function.
  ///
  /// Example:
  /// ```dart
  /// counter.update((v) => v + 1);
  /// ```
  void update(T Function(T current) fn) {
    value = fn(value);
  }

  /// Mutates the current value in place and forces a notification.
  ///
  /// This method is designed for **mutable objects** (models, lists, maps, etc.)
  /// where modifying the instance does not change the reference.
  ///
  /// Unlike [set] or [update], `mutate` **always triggers a notification**
  /// even if the underlying object reference stays the same.
  ///
  /// Use this when you intentionally modify the existing value instead of
  /// creating a new instance.
  ///
  /// Example:
  /// ```dart
  /// user.mutate((u) {
  ///   u.name = "Max";
  ///   u.age++;
  /// });
  /// ```
  ///
  /// ⚠️ Note:
  /// - Prefer immutable objects when possible
  /// - Use `mutate` only when in-place mutation is required
  void mutate(void Function(T value) mutator) {
    mutator(_value);
    notify();
  }

  /// Dispose everything when done.
  @override
  void dispose() {
    unsaveAll();
    super.dispose();
  }

  /// Combines multiple Reactive values (can be of different types) into a single Reactive.
  ///
  /// [dependencies] is the list of Reactive values to listen to.
  /// [combiner] receives a list of current values in the same order you pass them and returns a new value of type R.
  static ReadonlyReactive<R> _combine<R>(
    List<Reactive<dynamic>> dependencies,
    R Function(List<dynamic> values) combiner,
  ) {
    // Initial value
    final combined = ReadonlyReactive<R>(
      combiner(dependencies.map((r) => r.value).toList()),
    );

    // Callback to update combined whenever a source changes
    void update(_) {
      combined._set(combiner(dependencies.map((r) => r.value).toList()));
    }

    // Listen to all dependencies
    for (final dep in dependencies) {
      dep.listen(update);
    }

    return combined;
  }

  /// Same as combine but the combination function is not required
  static ReadonlyReactive<R> compute<R>(R Function() fn) {
    final tempComputed = ReadonlyReactive<R?>(null);
    BaseReactive._currentComputing = tempComputed;
    final value = fn();
    BaseReactive._currentComputing = null;

    final computed = ReadonlyReactive<R>(value);
    computed._computedReactives.addAll(tempComputed._computedReactives);

    void update(_) {
      computed._set(fn());
    }

    for (final dep in computed._computedReactives) {
      dep.listen(update);
    }

    return computed;
  }

  /// Combines two reactive values into a new [Reactive].
  ///
  /// The returned reactive is automatically updated whenever
  /// either [a] or [b] changes.
  ///
  /// The [combiner] callback receives the latest values of
  /// both reactives and must return the new combined value.
  ///
  /// This method keeps strong typing and avoids using `dynamic`.
  ///
  /// Example:
  /// ```dart
  /// final a = 1.reactive();
  /// final b = 2.reactive();
  ///
  /// final sum = Reactive.combine2(a, b, (x, y) => x + y);
  /// ```
  static ReadonlyReactive<R> combine2<A, B, R>(
    Reactive<A> a,
    Reactive<B> b,
    R Function(A a, B b) combiner,
  ) {
    return Reactive._combine([a, b], (l) => combiner(l[0] as A, l[1] as B));
  }

  /// Combines three reactive values into a new [Reactive].
  ///
  /// The returned reactive is updated whenever any of the
  /// provided reactives changes.
  ///
  /// The [combiner] callback is called with the latest values
  /// of [a], [b] and [c], in the same order.
  ///
  /// This is useful for building derived state based on
  /// multiple independent reactives.
  ///
  /// Example:
  /// ```dart
  /// final counter = 0.reactive();
  /// final name = 'Andy'.reactive();
  /// final visible = true.reactive();
  ///
  /// final text = Reactive.combine3(
  ///   counter,
  ///   name,
  ///   visible,
  ///   (c, n, v) => '$n: $c (${v ? "on" : "off"})',
  /// );
  /// ```
  static ReadonlyReactive<R> combine3<A, B, C, R>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    R Function(A a, B b, C c) combiner,
  ) {
    return Reactive._combine([
      a,
      b,
      c,
    ], (l) => combiner(l[0] as A, l[1] as B, l[2] as C));
  }

  /// Same thing as [combine2] and [combine3], but for four reactives.
  static ReadonlyReactive<R> combine4<A, B, C, D, R>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    Reactive<D> d,
    R Function(A a, B b, C c, D d) combiner,
  ) {
    return Reactive._combine([
      a,
      b,
      c,
      d,
    ], (l) => combiner(l[0] as A, l[1] as B, l[2] as C, l[3] as D));
  }

  /// Same thing as [combine2], [combine3] but for five reactives.
  static ReadonlyReactive<R> combine5<A, B, C, D, E, R>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    Reactive<D> d,
    Reactive<E> e,
    R Function(A a, B b, C c, D d, E e) combiner,
  ) {
    return Reactive._combine([
      a,
      b,
      c,
      d,
      e,
    ], (l) => combiner(l[0] as A, l[1] as B, l[2] as C, l[3] as D, l[4] as E));
  }

  /// Returns another reactive based on this one using [parser]
  ///
  /// Example:
  /// ```dart
  /// final list = Reactive([]);
  /// final length = list.as((l)=>l.length);
  /// ```
  @override
  Reactive<R> as<R>(R Function(T v) parser) {
    final r = Reactive(parser(value), strict);

    listen((v) {
      r.value = parser(v);
    });

    return r;
  }

  /// Shortcut for [ReactiveBuilder]
  @override
  ReactiveBuilder<T> build(Widget Function(T v) builder) {
    return ReactiveBuilder<T>(reactive: this, builder: builder);
  }

  /// Add a new validator
  @override
  Reactive<T> require(bool Function(T v) validator, [String? message]) {
    _validators.add(ReactiveValidator(validator, message));
    return this;
  }

  /// Save the current value under a specific [id].
  void save([String id = 'default']) {
    _savedStates[id] = _value;
  }

  /// Restores a previously saved value by [id].
  void restore([String id = 'default']) {
    if (_savedStates.containsKey(id)) {
      set(_savedStates[id] as T);
    }
  }

  /// Removes a saved state by [id].
  void unsave([String id = 'default']) {
    _savedStates.remove(id);
  }

  /// Removes all saved states.
  void unsaveAll() {
    _savedStates.clear();
  }

  /// Runs a block of code within a transaction, allowing for automatic rollback on error.
  /// If [rollbackOnError] is true, any error thrown in the block will trigger a rollback of all changes made to Reactive instances during the transaction.
  /// The optional [onError] callback can be used to handle errors without rolling back.
  static FutureOr<ReactiveTransaction> run(
    FutureOr<void> Function() block, {
    bool rollbackOnError = true,
    void Function(Object error)? onError,
  }) => ReactiveTransactionManager._run(
    block,
    rollbackOnError: rollbackOnError,
    onError: onError,
  );

  /// Returns the string representation of the current value.
  @override
  String toString() {
    return _value.toString();
  }
}
