part of 'package:flutter_reactive/flutter_reactive.dart';

/// Represents a transaction that tracks changes to Reactive instances.
/// Allows for batching updates and rolling back changes if needed.
class ReactiveTransaction {
  final String _id;
  final List<Reactive> _reactives = [];

  ReactiveTransaction()
    : _id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Registers a Reactive instance to be tracked in this transaction.
  void _track(Reactive reactive) {
    if (!_reactives.contains(reactive)) {
      reactive.save(_id);
      _reactives.add(reactive);
    }
  }

  /// Rolls back all changes made to Reactive instances in this transaction.
  void rollback() {
    for (final reactive in _reactives) {
      reactive.restore(_id);
      reactive.unsave(_id);
    }
    _reactives.clear();
  }
}
