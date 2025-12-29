import 'dart:math' as math;

import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension for [Reactive<num>] providing common numeric utilities.
extension ReactiveNum on Reactive<num> {
  /// Increments the numeric value by [by] (default: 1).
  ///
  /// Example:
  /// ```dart
  /// counter.increment(); // +1
  /// counter.increment(5); // +5
  /// ```
  void increment([num by = 1]) => value += by;

  /// Decrements the numeric value by [by] (default: 1).
  ///
  /// Example:
  /// ```dart
  /// counter.decrement(); // -1
  /// counter.decrement(3); // -3
  /// ```
  void decrement([num by = 1]) => value -= by;

  /// Alias for [increment].
  void inc([num by = 1]) => increment(by);

  /// Alias for [decrement].
  void dec([num by = 1]) => decrement(by);

  /// Returns true if the value is exactly zero.
  bool get isZero => value == 0;

  /// Returns true if the value is positive (> 0).
  bool get isPositive => value > 0;

  /// Returns true if the value is negative (< 0).
  bool get isNegative => value < 0;

  /// Clamps the numeric value between [min] and [max].
  ///
  /// Example:
  /// ```dart
  /// counter.clamp(0, 10);
  /// ```
  void clamp(int min, int max) {
    value = value.clamp(min, max);
  }

  /// Rounds the numeric value to [digits] decimal places.
  ///
  /// Example:
  /// ```dart
  /// price.roundTo(2); // 3.14159 => 3.14
  /// ```
  void roundTo(int digits) {
    final factor = math.pow(10, digits);
    value = (value * factor).round() / factor;
  }
}
