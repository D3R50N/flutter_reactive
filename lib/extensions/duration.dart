import 'package:flutter_reactive/flutter_reactive.dart';

extension ReactiveDuration on Reactive<Duration> {
  // Add a duration
  void add(Duration other) => value += other;

  // Remove a duration
  void remove(Duration other) => value -= other;

  // Multiply by a factor
  void multiply(double factor) =>
      value = Duration(microseconds: (value.inMicroseconds * factor).round());
}
