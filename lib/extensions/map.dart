import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension for [Reactive<Map<K, V>>] providing common map utilities.
extension ReactiveMap<K, V> on Reactive<Map<K, V>> {
  /// Inserts or updates a key-value pair in the reactive map.
  ///
  /// Example:
  /// ```dart
  /// settings.put('theme', 'dark');
  /// ```
  void put(K key, V value) {
    this.value = {...this.value, key: value};
  }

  /// Removes a key from the reactive map.
  ///
  /// Example:
  /// ```dart
  /// settings.remove('theme');
  /// ```
  void remove(K key) {
    final map = Map<K, V>.from(value);
    map.remove(key);
    value = map;
  }

  /// Returns true if the reactive map contains [key] and its value is not null.
  ///
  /// Example:
  /// ```dart
  /// if (settings.has('theme')) { ... }
  /// ```
  bool has(String key) => value.containsKey(key) && value[key] != null;

  /// Clears all entries in the reactive map.
  void clear() => value = {};
}
