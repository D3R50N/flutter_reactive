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

part 'core/transaction.dart';
part 'core/transaction_manager.dart';
part 'core/validator.dart';
part 'flutter_reactive_n.dart';

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
  Reactive(this._value, [this.strict = true]);

  /// Controls whether [stream] immediately emits the current value on subscription.
  ///
  /// When true, each new `stream.listen(...)` receives the current value through
  /// the broadcast stream as soon as the listener is attached.
  ///
  /// This setting is global for all [Reactive] instances.
  static bool streamEmitOnListen = true;

  T _value;

  /// Whether identical values should be ignored.
  ///
  /// When true, assigning a value equal to the current one does not notify
  /// listeners, streams, or bound widgets.
  final bool strict;

  /// States bound to this reactive.
  /// Every bound state will be rebuilt when the value changes.
  final List<State> _boundStates = [];

  /// Raw listeners notified on value changes.
  final List<_ReactiveListener<T>> _listeners = [];

  /// Validators to control incoming values.
  final List<ReactiveValidator<T>> _validators = [];

  final Map<String, T> _savedStates = {};

  final List<Reactive> _computedReactives = [];
  final Map<Reactive<dynamic>, _ReactiveListener<dynamic>>
  _computedDependencyListeners = {};

  static final List<Reactive<dynamic>> _computingStack = [];

  bool _readOnly = false;

  /// Internal broadcast controller used by [stream].
  late final _controller = StreamController<T>.broadcast(
    onListen: () {
      if (streamEmitOnListen) _notifyStreams();
    },
  );

  /// Current value of the reactive.
  T get value {
    if (_computingStack.isNotEmpty) {
      final current = _computingStack.last;
      if (!current._computedReactives.contains(this)) {
        current._computedReactives.add(this);
      }
    }
    return _value;
  }

  /// Exposes a broadcast stream of value changes.
  ///
  /// Depending on [streamEmitOnListen], a new subscriber may immediately receive
  /// the current value before future updates.
  Stream<T> get stream => _controller.stream;

  /// Updates the value and notifies listeners and bound states.
  set value(T newValue) => set(newValue);

  bool _equals(T newValue) {
    if (_value == newValue) return true;
    if (newValue is List) return listEquals(_value as List, newValue as List);
    if (newValue is Map) return mapEquals(_value as Map, newValue as Map);
    if (newValue is Set) return setEquals(_value as Set, newValue as Set);
    return false;
  }

  /// Sets a new value.
  ///
  /// If the reactive is read-only, it will throw an error
  /// If the value did not change, nothing happens.
  /// If the value is rejected by any validator, it is not updated and no notification occurs.
  /// If the value is updated, all bound states are rebuilt and listeners are notified.
  /// If the value is updated within a transaction, notifications are deferred until the transaction is committed.
  void set(T newValue) {
    if (_readOnly) throw Exception('Cannot modify a read-only Reactive');
    _set(newValue);
  }

  void _set(T newValue, [bool checkEquality = true]) {
    if (!_validate(newValue)) return;

    if (checkEquality && _equals(newValue) && strict) return;
    if (ReactiveTransactionManager._inTransaction) {
      ReactiveTransactionManager._register(this);
      _value =
          newValue; // register before changing value to capture the original state
    } else {
      _value = newValue;
      notify();
    }
  }

  /// Sets the value from a future once it completes.
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
    _set(_value, false);
  }

  /// Debounces value change notifications.
  ///
  void debounce(int milliseconds, _ReactiveListener<T> callback) {
    Timer? timer;
    listen((value) {
      timer?.cancel();
      timer = Timer(Duration(milliseconds: milliseconds), () {
        callback(value);
      });
    });
  }

  /// Throttle value change notifications.
  void throttle(int milliseconds, _ReactiveListener<T> callback) {
    Timer? timer;
    listen((value) {
      if (timer == null) {
        callback(value);
        timer = Timer(Duration(milliseconds: milliseconds), () => timer = null);
      }
    });
  }

  /// Triggers an action when a condition is met.
  /// The [condition] is evaluated on every value change, and when it returns true,
  /// the [action] is executed with the current value.
  void when(bool Function(T value) condition, void Function(T value) action) {
    listen((value) {
      if (condition(value)) {
        action(value);
      }
    });
  }

  /// Notifies both bound states, listeners and stream.
  void notify() {
    _notifyStreams();
    _notifyBoundStates();
    _notifyListeners();
  }

  void _notifyStreams() {
    _controller.add(_value);
  }

  /// Notifies all listeners with the current value.
  void _notifyListeners() {
    for (final callback in List<_ReactiveListener<T>>.from(_listeners)) {
      try {
        callback(value);
      } catch (_) {}
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
  ///
  /// If [emitInitial] is true, the callback is also invoked right away
  /// with the current value.
  void listen(_ReactiveListener<T> callback, [bool emitInitial = false]) {
    if (!_listeners.contains(callback)) {
      _listeners.add(callback);
    }

    if (emitInitial) {
      callback(value);
    }
  }

  /// Dispose everything when done.
  void dispose() {
    unsaveAll();
    _clearComputedDependencyListeners();
    _listeners.clear();
    _boundStates.clear();
    _controller.close();
    // should clean computed ?
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
  /// [dependencies] is the list of Reactive values to listen to.
  /// [combiner] receives a list of current values in the same order you pass them and returns a new value of type R.
  static Reactive<R> combine<R>(
    List<Reactive<dynamic>> dependencies,
    R Function(List<dynamic> values) combiner,
  ) {
    // Initial value
    final combined = Reactive<R>(
      combiner(dependencies.map((r) => r.value).toList()),
    );
    combined._readOnly = true;

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
  static Reactive<R> compute<R>(R Function() fn) {
    final tempComputed = ReactiveN<R>();
    final value = _trackDependencies(tempComputed, fn);

    final computed = Reactive<R>(value);
    computed._readOnly = true;
    computed._computedReactives.addAll(tempComputed._computedReactives);

    void update(_) {
      computed._clearComputedDependencyListeners();
      computed._computedReactives.clear();
      final newValue = _trackDependencies(computed, fn);
      computed._set(newValue);
      computed._listenToComputedDependencies(update);
    }

    computed._listenToComputedDependencies(update);

    return computed;
  }

  void _listenToComputedDependencies(_ReactiveListener<dynamic> listener) {
    for (final dep in _computedReactives) {
      dep.listen(listener);
      _computedDependencyListeners[dep] = listener;
    }
  }

  void _clearComputedDependencyListeners() {
    for (final entry in _computedDependencyListeners.entries) {
      entry.key.unlisten(entry.value);
    }
    _computedDependencyListeners.clear();
  }

  static R _trackDependencies<R>(Reactive<dynamic> target, R Function() fn) {
    _computingStack.add(target);
    try {
      return fn();
    } finally {
      _computingStack.removeLast();
    }
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
  static Reactive<R> combine2<A, B, R>(
    Reactive<A> a,
    Reactive<B> b,
    R Function(A a, B b) combiner,
  ) {
    return Reactive.combine([a, b], (l) => combiner(l[0] as A, l[1] as B));
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
  static Reactive<R> combine3<A, B, C, R>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    R Function(A a, B b, C c) combiner,
  ) {
    return Reactive.combine([
      a,
      b,
      c,
    ], (l) => combiner(l[0] as A, l[1] as B, l[2] as C));
  }

  /// Same thing as [combine2] and [combine3], but for four reactives.
  static Reactive<R> combine4<A, B, C, D, R>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    Reactive<D> d,
    R Function(A a, B b, C c, D d) combiner,
  ) {
    return Reactive.combine([
      a,
      b,
      c,
      d,
    ], (l) => combiner(l[0] as A, l[1] as B, l[2] as C, l[3] as D));
  }

  /// Same thing as [combine2], [combine3] but for five reactives.
  static Reactive<R> combine5<A, B, C, D, E, R>(
    Reactive<A> a,
    Reactive<B> b,
    Reactive<C> c,
    Reactive<D> d,
    Reactive<E> e,
    R Function(A a, B b, C c, D d, E e) combiner,
  ) {
    return Reactive.combine([
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
  Reactive<R> as<R>(R Function(T v) parser) {
    final r = Reactive(parser(value), strict);
    r._readOnly = true;

    listen((v) {
      r._set(parser(v));
    });

    return r;
  }

  /// Shortcut for [ReactiveBuilder]
  Widget build(Widget Function(T v) builder) {
    return ReactiveBuilder.watch(this, builder);
  }

  /// Adds a validator and returns this reactive for chaining.
  Reactive<T> require(bool Function(T v) validator, [String? message]) {
    _validators.add(ReactiveValidator(validator, message));
    return this;
  }

  bool _validate(T value) {
    for (final validator in _validators) {
      final valid = validator.run(value);
      if (!valid) return false;
    }
    return true;
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
    return value.toString();
  }
}
