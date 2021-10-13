import 'package:collection/collection.dart';
import 'package:safechat/utils/validator.dart';

enum FStatus { init, valid, invalid, loading, success, failure }

abstract class FormItem<T> {
  const FormItem._(this.value, [this.blank = false]);

  const FormItem(T value) : this._(value);
  const FormItem.blank(T value) : this._(value, true);

  final T value;
  final bool blank;

  List<Validator> get validators;

  bool get isValid => validators.every((v) => v.isValid(value));

  String? get error => blank
      ? null
      : validators.firstWhereOrNull((v) => !v.isValid(value))?.errorText;
}

class FormStatus {
  const FormStatus({
    required this.status,
    this.error,
  });

  static const FormStatus init = FormStatus(status: FStatus.init);
  static const FormStatus valid = FormStatus(status: FStatus.valid);
  static const FormStatus invalid = FormStatus(status: FStatus.invalid);
  static const FormStatus loading = FormStatus(status: FStatus.loading);
  static const FormStatus success = FormStatus(status: FStatus.success);

  const FormStatus.failure(String error)
      : this(status: FStatus.failure, error: error);

  final FStatus status;
  final String? error;

  static FormStatus validate(List<FormItem> items) {
    return items.every((item) => item.isValid)
        ? FormStatus.valid
        : FormStatus.invalid;
  }
}

extension FormStatusExtenstion on FormStatus {
  bool get isInit => status == FStatus.init;
  bool get isValid => status == FStatus.valid;
  bool get isInvalid => status == FStatus.invalid;
  bool get isLoading => status == FStatus.loading;
  bool get isSuccess => status == FStatus.success;
  bool get isFailure => status == FStatus.failure;
}
