// ignore_for_file: public_member_api_docs, sort_constructors_first

class ValidatorError<T> implements Exception {
  final String? _message;
  final T? value;

  String get message =>
      ((_message ?? "").trim() == "")
          ? "ValidatorError: INVALID_VALUE ${value != null ? "($value)" : ""}"
          : _message!;

  ValidatorError({String? message, this.value}) : _message = message;

  @override
  String toString() => message;
}

class Validator<T> {
  final bool Function(T v) validator;
  final String? message;

  Validator(this.validator, [this.message]);

  bool run(T v) {
    if (validator(v)) return true;
    if (message != null) throw ValidatorError(value: v, message: message);
    return false;
  }
}
