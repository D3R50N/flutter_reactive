part of 'package:flutter_reactive/flutter_reactive.dart';

/// Manages transactions for Reactive instances, allowing for batching updates and rollbacks.
class ReactiveTransactionManager {
  ReactiveTransactionManager._();

  static ReactiveTransaction? _current;

  static bool get _inTransaction => _current != null;

  /// Registers a Reactive instance to be tracked in the current transaction, if any.
  static void _register(Reactive reactive) {
    _current?._track(reactive);
  }

  /// Flushes all changes made in the transaction by notifying the tracked Reactive instances.
  static void _flush(ReactiveTransaction transaction) {
    for (final r in transaction._reactives) {
      r.notify();
    }
  }

  /// Runs a block of code within a transaction, allowing for automatic rollback on error.
  /// If [rollbackOnError] is true, any error thrown in the block will trigger a rollback of all changes made to Reactive instances during the transaction.
  /// The optional [onError] callback can be used to handle errors without rolling back.
  static FutureOr<ReactiveTransaction> _run(
    FutureOr<void> Function() block, {
    bool rollbackOnError = true,
    void Function(Object error)? onError,
  }) async {
    final transaction = ReactiveTransaction();
    _current = transaction;

    try {
      await block();
      _current = null;
      _flush(transaction);
    } catch (e) {
      _current = null;

      if (rollbackOnError) {
        transaction.rollback();
      }

      onError?.call(e);
    }

    return transaction;
  }
}
