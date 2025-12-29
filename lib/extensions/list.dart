import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension for [Reactive<List<T>>] providing common list utilities.
extension ReactiveList<T> on Reactive<List<T>> {
  /// Returns true if the list is empty.
  bool get isEmpty => value.isEmpty;

  /// Returns true if the list is not empty.
  bool get isNotEmpty => value.isNotEmpty;

  /// Returns the length of the list.
  int get length => value.length;

  /// Adds [item] to the end of the list.
  void add(T item) => value = [...value, item];

  /// Adds all items from [items] to the end of the list.
  void addAll(Iterable<T> items) => value = [...value, ...items];

  /// Adds [item] to the list only if it does not already exist.
  void addToSet(T item) {
    if (!value.contains(item)) value = [...value, item];
  }

  /// Removes [item] from the list.
  void remove(T item) {
    value.remove(item);
    notify();
  }

  /// Removes all elements that match [test].
  void removeWhere(bool Function(T) test) =>
      value = value.where((e) => !test(e)).toList();

  /// Removes all occurrences of [item].
  void removeAll(T item) => value = value.where((e) => e != item).toList();

  /// Clears the list.
  void clear() => value = [];

  /// Returns a filtered list containing elements that satisfy [test].
  List<T> where(bool Function(T) test) => value.where((e) => test(e)).toList();

  /// Returns the first element that satisfies [test], or null if none found.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in value) {
      if (test(e)) return e;
    }
    return null;
  }
}
