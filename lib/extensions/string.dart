import 'package:flutter_reactive/flutter_reactive.dart';

/// Extension for [Reactive<String>] providing common string utilities.
extension ReactiveString on Reactive<String> {
  /// Returns true if the string is empty after trimming whitespace.
  bool get isEmpty => value.trim().isEmpty;

  /// Returns true if the string is not empty after trimming whitespace.
  bool get isNotEmpty => value.trim().isNotEmpty;

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
}
