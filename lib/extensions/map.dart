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

  /// Returns the value associated with [k], if present.
  V? operator [](K k) {
    return value[k];
  }

  /// Sets the value for key [k] to [v] and notifies listeners.
  void operator []=(K k, V v) {
    value[k] = v;
    notify();
  }

  /// Applies [action] to each key-value pair in the map.
  void forEach(void Function(K k, V v) action) {
    value.forEach(action);
  }

  /// Returns the value associated with [k], if present.
  V? get(K k) {
    return value[k];
  }

  /// The map keys.
  Iterable<K> get keys => value.keys;

  /// The map values.
  Iterable<V> get values => value.values;

  /// The map entries.
  Iterable<MapEntry<K, V>> get entries => value.entries;
}
