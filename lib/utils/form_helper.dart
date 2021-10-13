import 'package:collection/collection.dart';
import 'package:safechat/utils/validator.dart';

enum FStatus { init, submiting, loading, success, failure }
enum VStatus { valid, invalid }

abstract class FormItem<T> {
  const FormItem(this.value);

  final T value;
  List<Validator> get validators;

  bool get isValid => validators.every((v) => v.isValid(value));

  String? get error => validators
      .firstWhereOrNull(
        (v) => !v.isValid(value),
      )
      ?.errorText;
}

class FormStatus {
  const FormStatus({
    required this.status,
    this.error,
  });

  static const FormStatus init = FormStatus(status: FStatus.init);

  static const FormStatus submiting = FormStatus(status: FStatus.submiting);
  static const FormStatus loading = FormStatus(status: FStatus.loading);
  static const FormStatus success = FormStatus(status: FStatus.success);
  const FormStatus.failure(String error)
      : this(status: FStatus.failure, error: error);

  final FStatus status;
  final String? error;
}

mixin ValidationMixin {
  VStatus get validate =>
      inputs.every((item) => item.isValid) ? VStatus.valid : VStatus.invalid;

  List<FormItem> get inputs;
}

extension VStatusExtension on VStatus {
  bool get isValid => this == VStatus.valid;
  bool get isInvalid => this == VStatus.invalid;
}

extension FormStatusExtenstion on FormStatus {
  bool get isInit => status == FStatus.init;
  bool get isSubmiting => status == FStatus.submiting;
  bool get isLoading => status == FStatus.loading;
  bool get isSuccess => status == FStatus.success;
  bool get isFailure => status == FStatus.failure;
}
