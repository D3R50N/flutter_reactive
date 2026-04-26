import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension for [Reactive<String>] providing common string utilities.
extension ReactiveString on Reactive<String> {
  /// Returns true if the string is empty after trimming whitespace.
  bool get isEmpty => value.trim().isEmpty;

  /// Returns true if the string is not empty after trimming whitespace.
  bool get isNotEmpty => value.trim().isNotEmpty;

  /// Returns the length of the string.
  int get length => value.length;

  /// Clears the string, setting it to an empty value.
  void clear() => value = '';

  /// Appends [text] to the current string.
  void append(String text) => value += text;

  /// Prepends [text] to the current string.
  void prepend(String text) => value = '$text$value';

  /// Trims whitespace from the start and end of the string.
  void trim() => value = value.trim();

  /// Converts the string to uppercase.
  void toUpper() => value = value.toUpperCase();

  /// Converts the string to lowercase.
  void toLower() => value = value.toLowerCase();

  String get upper => value.toUpperCase();
  String get lower => value.toLowerCase();

  /// Returns the trimmed value
  String get trimmed => value.trim();

  /// Checks if the string contains [other].
  ///
  /// [caseSensitive] determines whether the search is case-sensitive (default: true).
  ///
  /// Example:
  /// ```dart
  /// final name = react('Flutter');
  /// name.contains('flut', caseSensitive: false); // true
  /// ```
  bool contains(String other, {bool caseSensitive = true}) {
    final v = caseSensitive ? value : value.toLowerCase();
    final t = caseSensitive ? other : other.toLowerCase();
    return v.contains(t);
  }

  /// Returns true if the string starts with [other].
  bool startsWith(Object other, {bool caseSensitive = true}) {
    final v = caseSensitive ? value : value.toLowerCase();
    final t = caseSensitive ? _resolve(other) : _resolve(other).toLowerCase();
    return v.startsWith(t);
  }

  /// Returns true if the string ends with [other].
  bool endsWith(Object other, {bool caseSensitive = true}) {
    final v = caseSensitive ? value : value.toLowerCase();
    final t = caseSensitive ? _resolve(other) : _resolve(other).toLowerCase();
    return v.endsWith(t);
  }

  String _resolve(Object other) =>
      other is Reactive<String> ? other.value : other.toString();

  /// Concatenates this value with [other] and returns a new [String].
  ///
  /// ```dart
  /// rFirst + rLast   // String
  /// rFirst + ' world' // String
  /// ```
  String operator +(Object other) => value + _resolve(other);

  /// Returns true if this value is less than [other] (lexicographic order).
  bool operator <(Object other) => value.compareTo(_resolve(other)) < 0;

  /// Returns true if this value is less than or equal to [other].
  bool operator <=(Object other) => value.compareTo(_resolve(other)) <= 0;

  /// Returns true if this value is greater than [other].
  bool operator >(Object other) => value.compareTo(_resolve(other)) > 0;

  /// Returns true if this value is greater than or equal to [other].
  bool operator >=(Object other) => value.compareTo(_resolve(other)) >= 0;
}
