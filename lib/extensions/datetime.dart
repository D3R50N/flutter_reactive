import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension for [Reactive<DateTime>] providing common date utilities.
extension ReactiveDateTime on Reactive<DateTime> {
  /// Adds [days] to the current date.
  void addDays(int days) => value = value.add(Duration(days: days));

  /// Subtracts [days] from the current date.
  void subtractDays(int days) => value = value.subtract(Duration(days: days));

  /// Returns true if the current date is in the future.
  bool get isFuture => value.isAfter(DateTime.now());

  /// Returns true if the current date is in the past.
  bool get isPast => value.isBefore(DateTime.now());
}
