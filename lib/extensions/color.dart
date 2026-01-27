// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

extension ReactiveColor on Reactive<Color> {
  /// Lighten color
  void lighten(double factor) =>
      value = Color.lerp(value, Colors.white, factor)!;

  /// Darken color
  void darken(double factor) =>
      value = Color.lerp(value, Colors.black, factor)!;

  /// Invert color.
  void invert() =>
      value = Color.fromRGBO(
        255 - value.red,
        255 - value.green,
        255 - value.blue,
        value.opacity,
      );

  /// Check if dark.
  bool get isDark =>
      (value.red * 0.299 + value.green * 0.587 + value.blue * 0.114) < 128;
}
