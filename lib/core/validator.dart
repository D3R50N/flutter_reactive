part of 'package:flutter_reactive/flutter_reactive.dart';

class ReactiveValidatorError<T> implements Exception {
  final String? _message;
  final T? value;

  String get message =>
      ((_message ?? "").trim() == "")
          ? "ValidatorError: INVALID_VALUE ${value != null ? "($value)" : ""}"
          : _message!;

  ReactiveValidatorError({String? message, this.value}) : _message = message;

  @override
  String toString() => message;
}

/// Validator for Reactive values, allowing for custom validation logic and error handling.
class ReactiveValidator<T> {
  final bool Function(T v) validator;
  final String? message;

  ReactiveValidator(this.validator, [this.message]);

  bool run(T v) {
    if (validator(v)) return true;
    if (message != null) {
      throw ReactiveValidatorError(value: v, message: message);
    }
    return false;
  }
}
