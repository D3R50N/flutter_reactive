import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive/extensions/state.dart';

export 'extensions/all.dart';
export 'extensions/bool.dart';
export 'extensions/list.dart';
export 'extensions/map.dart';
export 'extensions/num.dart';
export 'extensions/state.dart';
export 'extensions/string.dart';
export 'widgets/reactive_builder.dart';
export 'widgets/stream_builder.dart';

typedef _ReactiveListener<T> = void Function(T value);

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
class Reactive<T> {
  /// Creates a new [Reactive] with an initial value.
  Reactive(this._value);

  T _value;

  /// States bound to this reactive.
  /// Every bound state will be rebuilt when the value changes.
  final List<State> _boundStates = [];

  /// Raw listeners notified on value changes.
  final List<_ReactiveListener<T>> _listeners = [];

  /// Stream controller
  final _controller = StreamController<T>.broadcast();

  /// Current value of the reactive.
  T get value => _value;

  /// Expose a broadcast stream of value changes.
  Stream<T> get stream => _controller.stream;

  /// Updates the value and notifies listeners and bound states.
  set value(T newValue) => set(newValue);

  /// Sets a new value.
  ///
  /// If the value did not change, nothing happens.
  void set(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notify();
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

  /// Notifies both bound states, listeners and stream.
  void notify() {
    _notifyBoundStates();
    _notifyListeners();
    _controller.add(_value);
  }

  /// Notifies all listeners with the current value.
  void _notifyListeners() {
    for (final callback in _listeners) {
      callback(value);
    }
  }

  /// Rebuilds all bound states.
  ///
  /// Unmounted states are automatically removed
  /// to avoid memory leaks and invalid `setState` calls.
  void _notifyBoundStates() {
    _boundStates.removeWhere((state) => !state.mounted);

    for (final state in List<State>.from(_boundStates)) {
      state.updateState();
    }
  }

  /// Adds a listener that will be called on every value change.
  ///
  /// Listeners are value-based and **do not trigger UI rebuilds**
  /// unless you explicitly bind a [State].
  void listen(_ReactiveListener<T> callback) {
    if (!_listeners.contains(callback)) {
      _listeners.add(callback);
    }
  }

  /// Dispose everything when done.
  void dispose() {
    _listeners.clear();
    _boundStates.clear();
    _controller.close();
  }

  /// Removes a previously registered listener.
  void unlisten(_ReactiveListener<T> callback) => _listeners.remove(callback);

  /// Binds a Flutter [State] to this reactive.
  ///
  /// When the value changes, `setState()` will automatically
  /// be called on the bound state.
  ///
  /// Example:
  /// ```dart
  /// counter.bind(this);
  /// ```
  void bind(State state) {
    if (!_boundStates.contains(state)) {
      _boundStates.add(state);
      state.updateState(); // sync UI immediately
    }
  }

  /// Unbinds a previously bound [State].
  ///
  /// The state will no longer rebuild when the value changes.
  void unbind(State state) => _boundStates.remove(state);

  /// Combines multiple Reactive values (can be of different types) into a single Reactive.
  ///
  /// [sources] is the list of Reactive values to listen to.
  /// [combine] receives a list of current values and returns a new value of type R.
  static Reactive<R> combine<R>(
    List<Reactive<dynamic>> sources,
    R Function(List<dynamic> values) combine,
  ) {
    // Initial value
    final combined = Reactive<R>(combine(sources.map((r) => r.value).toList()));

    // Callback to update combined whenever a source changes
    void update(_) {
      combined.value = combine(sources.map((r) => r.value).toList());
    }

    // Listen to all sources
    for (final source in sources) {
      source.listen(update);
    }

    return combined;
  }

  /// Combines two reactive values into a new [Reactive].
  ///
  /// The returned reactive is automatically updated whenever
  /// either [a] or [b] changes.
  ///
  /// The [combine] callback receives the latest values of
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
  static Reactive<R> combine2<A, B, R>(
    Reactive<A> a,
    Reactive<B> b,
    R Function(A a, B b) combine,
  ) {
    return Reactive.combine([a, b], (l) => combine(l[0] as A, l[1] as B));
  }

  /// Combines three reactive values into a new [Reactive].
  ///
  /// The returned reactive is updated whenever any of the
  /// provided reactives changes.
  ///
  /// The [combine] callback is called with the latest values
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
  static Reactive<R> combine3<A, B, C, R>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    R Function(A a, B b, C c) combine,
  ) {
    return Reactive.combine([
      a,
      b,
      c,
    ], (l) => combine(l[0] as A, l[1] as B, l[2] as C));
  }

  /// Same thing as [combine2] and [combine3], but for four reactives.
  static Reactive<R> combine4<A, B, C, D, R>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    Reactive<D> d,
    R Function(A a, B b, C c, D d) combine,
  ) {
    return Reactive.combine([
      a,
      b,
      c,
      d,
    ], (l) => combine(l[0] as A, l[1] as B, l[2] as C, l[3] as D));
  }

  /// Same thing as [combine2], [combine3] but for five reactives.
  static Reactive<R> combine5<A, B, C, D, E, R>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    Reactive<D> d,
    Reactive<E> e,
    R Function(A a, B b, C c, D d, E e) combine,
  ) {
    return Reactive.combine([
      a,
      b,
      c,
      d,
      e,
    ], (l) => combine(l[0] as A, l[1] as B, l[2] as C, l[3] as D, l[4] as E));
  }

  /// Returns the string representation of the current value.
  @override
  String toString() {
    return _value.toString();
  }
}
