part of 'package:flutter_reactive/flutter_reactive.dart';

/// A subscription to a Reactive instance, allowing for unlistening and cleanup.
class ReactiveSubscription<T> {
  final Reactive<T> _reactive;
  final _ReactiveListener<T> _listener;
  VoidCallback? _onCancel;

  ReactiveSubscription(
    this._reactive,
    this._listener, {
    bool emitInitial = false,
    VoidCallback? onCancel,
  }) : _onCancel = onCancel {
    if (!_reactive._listeners.contains(_listener)) {
      _reactive._listeners.add(_listener);
    }
    if (emitInitial) _listener(_reactive._value);
  }

  /// Get the current value of the reactive variable.
  T get currentValue => _reactive._value;

  /// Unsubscribe from the reactive updates.
  void cancel() {
    _reactive._listeners.remove(_listener);
    _onCancel?.call();
  }
}
