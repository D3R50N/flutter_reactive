import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension for [Reactive<Iterable<T>>] providing common list utilities.
extension ReactiveIterable<T> on Reactive<Iterable<T>> {
  /// Returns the first element.
  T get first => value.first;

  /// Returns the first element, or `null` if the iterable is empty.
  T? get firstOrNull => value.firstOrNull;

  /// Returns the last element.
  T get last => value.last;

  /// Returns the last element, or `null` if the iterable is empty.
  T? get lastOrNull => value.lastOrNull;

  /// Returns true if the list is empty.
  bool get isEmpty => value.isEmpty;

  /// Returns true if the list is not empty.
  bool get isNotEmpty => value.isNotEmpty;

  /// Returns the length of the list.
  int get length => value.length;

  /// Returns the current iterable as a new [List].
  List<T> toList() {
    return value.toList();
  }

  /// Applies [action] to each element of the current iterable.
  void forEach(void Function(T e) action) {
    value.forEach(action);
  }

  /// Returns a filtered list containing elements that satisfy [test].
  List<T> where(bool Function(T) test) => value.where((e) => test(e)).toList();

  /// Returns the first element that satisfies [test], or null if none found.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in value) {
      if (test(e)) return e;
    }
    return null;
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
    final r = as((l) {
      var filtered = l.where(filter ?? (_) => true).toList();
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

      return filtered;
    });

    return r;
  }

  /// Returns the element at [index].
  T operator [](int index) {
    return value.elementAt(index);
  }

  /// Returns the element at [index].
  T at(int index) {
    return value.elementAt(index);
  }

  /// Returns the element at [index], or `null` if out of range.
  T? atOrNull(int index) {
    return value.elementAtOrNull(index);
  }
}

/// Extension for [Reactive<List<T>>] providing immutable-style list updates.
extension ReactiveList<T> on Reactive<List<T>> {
  /// Adds [item] to the end of the list.
  void add(T item) => value = [...value, item];

  /// Adds [item] to the end of the list.
  void addFirst(T item) => value = [item, ...value];

  /// Adds all items from [items] to the end of the list.
  void addAll(Iterable<T> items) => value = [...value, ...items];

  /// Adds [item] to the list only if it does not already exist.
  void addToSet(T item) {
    if (!value.contains(item)) value = [...value, item];
  }

  /// Removes [item] from the list.
  void remove(T item) {
    if (!value.contains(item)) return;

    final list = toList();
    list.remove(item);
    value = list;
  }

  /// Removes all elements that match [test].
  void removeWhere(bool Function(T) test) =>
      value = value.where((e) => !test(e)).toList();

  /// Removes all occurrences of [item].
  void removeAll(T item) => value = value.where((e) => e != item).toList();

  /// Clears the list.
  void clear() => value = [];

  /// Sort the list in place using the provided [compare] function.
  void sort([int Function(T a, T b)? compare]) {
    final list = value.toList();

    list.sort(compare);
    value = list;
  }

  /// Returns the element at [index].
  T operator [](int index) {
    return value[index];
  }

  /// Replaces the element at index [i] with [v] and notifies listeners.
  void operator []=(int i, T v) {
    value[i] = v;
    notify();
  }
}
