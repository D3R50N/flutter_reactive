import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension on all types to quickly create a [Reactive] wrapper.
extension ReactiveAll<T> on T {
  /// Converts any value into a [Reactive<T>] instance.
  ///
  /// Example:
  /// ```dart
  /// final counter = 0.rt; // Reactive<int>
  /// final title = 'Hello'.rt; // Reactive<String>
  /// final enabled = true.rt; // Reactive<bool>
  /// ```
  Reactive<T> get rt {
    return Reactive(this);
  }

  /// Extension to create a [ReactiveN] wrapper for any type.
  ReactiveN<T> get rtn {
    return ReactiveN(this);
  }

  /// Creates a non-strict [Reactive] wrapper for this value.
  Reactive<T> get rtNonStrict {
    return Reactive(this, false);
  }

  /// Creates a non-strict [ReactiveN] wrapper for this value.
  ReactiveN<T> get rtnNonStrict {
    return ReactiveN(this, false);
  }
}
