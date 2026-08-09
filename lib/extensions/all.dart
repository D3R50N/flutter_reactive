import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension on all types to quickly create a [Reactive] wrapper.
extension ReactiveAll<T> on T {
  /// Converts any value into a [Reactive<T>] instance.
  ///
  /// Example:
  /// ```dart
  /// final counter = 0.rx; // Reactive<int>
  /// final title = 'Hello'.rx; // Reactive<String>
  /// final enabled = true.rx; // Reactive<bool>
  /// ```
  Reactive<T> get rx {
    return Reactive(this);
  }

  /// Creates a non-strict [Reactive] wrapper for this value.
  Reactive<T> get rxNonStrict {
    return Reactive(this, false);
  }
}

