part of '../flutter_reactive.dart';

typedef _ReactiveListener<T> = void Function(T value);

sealed class BaseReactive<T> {
  BaseReactive(this._value, [this.strict = true]);

  T _value;
  final bool strict;

  /// States bound to this reactive.
  /// Every bound state will be rebuilt when the value changes.
  final List<State> _boundStates = [];

  /// Raw listeners notified on value changes.
  final List<_ReactiveListener<T>> _listeners = [];

  /// Validators to control incoming values.
  final List<ReactiveValidator<T>> _validators = [];

  static ReadonlyReactive? _currentComputing;

  final
      /// Stream controller
      _controller =
      StreamController<T>.broadcast();

  /// Expose a broadcast stream of value changes.
  Stream<T> get stream => _controller.stream;

  /// Current value of the reactive.
  T get value {
    if (_currentComputing != null) {
      if (!_currentComputing!._computedReactives.contains(this)) {
        _currentComputing!._computedReactives.add(this);
      }
    }
    return _value;
  }

  bool _equals(T newValue) {
    if (_value == newValue) return true;
    if (newValue is List) return listEquals(_value as List, newValue as List);
    return false;
  }

  void _set(T newValue) {
    for (final v in _validators) {
      final valid = v.run(newValue);
      if (!valid) return;
    }

    if (_equals(newValue) && strict) return;
    if (ReactiveTransactionManager._inTransaction && this is Reactive) {
      ReactiveTransactionManager._register(this as Reactive);
      _value =
          newValue; // register before changing value to capture the original state
    } else {
      _value = newValue;
      notify();
    }
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
    _notifyBoundStates();
    _notifyListeners();
    _controller.add(_value);
  }

  /// Notifies all listeners with the current value.
  void _notifyListeners() {
    for (final callback in _listeners) {
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

  /// Returns another reactive based on this one using [parser]
  ///
  /// Example:
  /// ```dart
  /// final list = Reactive([]);
  /// final length = list.as((l)=>l.length);
  /// ```
  BaseReactive<R> as<R>(R Function(T v) parser) {
    final r = Reactive(parser(value), strict);

    listen((v) {
      r.value = parser(v);
    });

    return r;
  }

  /// Shortcut for [ReactiveBuilder]
  ReactiveBuilder<T> build(Widget Function(T v) builder) {
    return ReactiveBuilder<T>(reactive: this, builder: builder);
  }

  /// Add a new validator
  BaseReactive<T> require(bool Function(T v) validator, [String? message]) {
    _validators.add(ReactiveValidator(validator, message));
    return this;
  }

  /// Returns the string representation of the current value.
  @override
  String toString() {
    return _value.toString();
  }
}
