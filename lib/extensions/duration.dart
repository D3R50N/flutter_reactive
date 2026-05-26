import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension for [Reactive<Duration>] providing common duration utilities.
extension ReactiveDuration on Reactive<Duration> {
  /// Adds [other] to the current duration.
  void add(Duration other) => value += other;

  /// Subtracts [other] from the current duration.
  void remove(Duration other) => value -= other;

  /// Multiplies the current duration by [factor].
  void multiply(double factor) =>
      value = Duration(microseconds: (value.inMicroseconds * factor).round());
}
