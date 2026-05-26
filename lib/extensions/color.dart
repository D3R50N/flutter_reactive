// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension for [Reactive<Color>] providing common color utilities.
extension ReactiveColor on Reactive<Color> {
  /// Lightens the current color toward white by [factor].
  void lighten(double factor) =>
      value = Color.lerp(value, Colors.white, factor)!;

  /// Darkens the current color toward black by [factor].
  void darken(double factor) =>
      value = Color.lerp(value, Colors.black, factor)!;

  /// Inverts the current RGB color channels.
  void invert() =>
      value = Color.fromRGBO(
        255 - value.red,
        255 - value.green,
        255 - value.blue,
        value.opacity,
      );

  /// Returns true when the current color is perceived as dark.
  bool get isDark =>
      (value.red * 0.299 + value.green * 0.587 + value.blue * 0.114) < 128;
}
