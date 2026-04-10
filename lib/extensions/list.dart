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

  /// Sort the list in place using the provided [compare] function.
  void sort([int Function(T a, T b)? compare]) {
    value.sort(compare);
    notify();
  }

  /// Transforms the current reactive list into a new reactive list by applying
  /// optional filtering, sorting, and list operations.
  ///
  /// This method listens to changes on the source reactive list and keeps the
  /// returned reactive list in sync after applying the given transformations.
  ///
  /// Parameters:
  /// - [filter]: A predicate used to filter elements.
  ///   If null, all elements are kept.
  /// - [sortBy]: A function that returns a comparable value used to sort elements.
  ///   If null, no sorting is applied.
  /// - [sortByDesc]: Whether sorting should be in descending order.
  ///   Only used when [sortBy] is provided. Defaults to false.
  /// - [reverse]: Whether to reverse the resulting list.
  /// - [shuffle]: Whether to shuffle the resulting list randomly.
  /// - [take]: Limits the number of elements in the resulting list.
  ///
  /// Returns:
  /// A new [Reactive<List<T>>] that reflects the transformed version of the
  /// source list and updates automatically when the source list changes.
  ///
  /// Example:
  /// ```dart
  /// final users = Reactive<List<User>>([...]);
  ///
  /// final topActiveUsers = users.transform(
  ///   filter: (u) => u.isActive,
  ///   sortBy: (u) => u.score,
  ///   sortByDesc: true,
  ///   take: 10,
  /// );
  /// ```
  ///
  /// In this example, the returned reactive list will always contain the
  /// top 10 active users sorted by score in descending order.
  Reactive<List<T>> transform({
    bool Function(T element)? filter,
    Comparable<dynamic> Function(T element)? sortBy,
    bool? sortByDesc,
    bool? reverse,
    bool? shuffle,
    int? take,
  }) {
    testTrue(_) => true;

    final r = Reactive(value.where(filter ?? testTrue).toList(), strict);

    listen((l) {
      var filtered = l.where(filter ?? testTrue).toList();
      if (sortBy != null) {
        filtered.sort((a, b) {
          if (sortByDesc == true) return sortBy(b).compareTo(sortBy(a));
          return sortBy(a).compareTo(sortBy(b));
        });
      }
      if (reverse == true) {
        filtered = filtered.reversed.toList();
      }
      if (shuffle == true) {
        filtered.shuffle();
      }
      if (take != null) {
        filtered = filtered.take(take).toList();
      }

      r.value = filtered;
    });

    return r;
  }
}
