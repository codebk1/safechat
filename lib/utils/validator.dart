abstract class Validator<T> {
  Validator(this.errorText);

  final String errorText;

  bool isValid(T value);

  String? call(T value) {
    return isValid(value) ? null : errorText;
  }
}

class MultiValidator extends Validator<String?> {
  final List<Validator> validators;
  static String _errorText = '';

  MultiValidator(this.validators) : super(_errorText);

  @override
  bool isValid(value) {
    for (Validator validator in validators) {
      if (validator.call(value) != null) {
        _errorText = validator.errorText;
        return false;
      }
    }
    return true;
  }

  @override
  String? call(dynamic value) {
    return isValid(value) ? null : _errorText;
  }
}

class RequiredValidator extends Validator<String> {
  RequiredValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(value) {
    return value.isNotEmpty;
  }
}

class EmailValidator extends Validator<String> {
  EmailValidator([String? errorText])
      : super(errorText ?? 'Podany email jest niepoprawny.');

  @override
  bool isValid(String value) {
    final regExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    );

    return regExp.hasMatch(value);
  }
}

class MatchValidator extends Validator<String> {
  MatchValidator(this.firstValue, [String? errorText])
      : super(errorText ?? 'Podane wartości różnią się.');

  final String firstValue;

  @override
  bool isValid(String value) {
    return firstValue == value;
  }
}
