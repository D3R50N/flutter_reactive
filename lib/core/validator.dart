part of 'package:flutter_reactive/flutter_reactive.dart';

/// An exception thrown when a [ReactiveValidator] rejects a value.
class ReactiveValidatorError<T> implements Exception {
  final String? _message;

  /// The value that failed validation, if available.
  final T? value;

  /// The resolved validation error message.
  String get message =>
      ((_message ?? "").trim() == "")
          ? "ValidatorError: INVALID_VALUE ${value != null ? "($value)" : ""}"
          : _message!;

  /// Creates a validator error with an optional custom [message].
  ReactiveValidatorError({String? message, this.value}) : _message = message;

  @override
  String toString() => message;
}

/// Validator for Reactive values, allowing for custom validation logic and error handling.
class ReactiveValidator<T> {
  /// The predicate used to validate incoming values.
  final bool Function(T v) validator;

  /// Optional error message used when validation fails.
  final String? message;

  /// Creates a validator from a predicate and an optional error message.
  ReactiveValidator(this.validator, [this.message]);

  /// Runs the validator against [v].
  ///
  /// Returns `true` when the value is accepted. If [message] is provided and
  /// validation fails, a [ReactiveValidatorError] is thrown.
  bool run(T v) {
    if (validator(v)) return true;
    if (message != null) {
      throw ReactiveValidatorError(value: v, message: message);
    }
    return false;
  }
}
