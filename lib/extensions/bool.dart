import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension for [Reactive<bool>] providing common boolean utilities.
extension ReactiveBool on Reactive<bool> {
  /// Toggles the boolean value between true and false.
  ///
  /// Example:
  /// ```dart
  /// isVisible.toggle();
  /// ```
  void toggle() => value = !value;

  /// Sets the value to true.
  void enable() => value = true;

  /// Sets the value to false.
  void disable() => value = false;

  /// Returns true if the value is true.
  bool get isTrue => value;

  /// Returns true if the value is false.
  bool get isFalse => !value;
}
