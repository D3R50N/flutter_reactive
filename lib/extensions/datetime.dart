import 'package:flutter_reactive/flutter_reactive.dart';

extension ReactiveDateTime on Reactive<DateTime> {
  /// Add days to date
  void addDays(int days) => value = value.add(Duration(days: days));

  /// Remove days from date
  void subtractDays(int days) => value = value.subtract(Duration(days: days));

  /// Check if is in future
  bool get isFuture => value.isAfter(DateTime.now());

  /// Check if is in past
  bool get isPast => value.isBefore(DateTime.now());
}
