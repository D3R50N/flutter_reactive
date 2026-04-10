import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension on all types to quickly create a [Reactive] wrapper.
extension ReactiveAll<T> on T {
  /// Converts any value into a [Reactive<T>] instance.
  ///
  /// Example:
  /// ```dart
  /// final counter = 0.reactive(); // Reactive<int>
  /// final title = 'Hello'.reactive(); // Reactive<String>
  /// final enabled = true.reactive(); // Reactive<bool>
  /// final nonStrictValue = 42.reactive(false); // Reactive<int> with strict mode disabled
  /// ```
  Reactive<T> reactive([bool strict = true]) {
    return Reactive(this, strict);
  }
}
