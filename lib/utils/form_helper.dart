import 'package:collection/collection.dart';

import 'package:safechat/utils/utils.dart';

enum FStatus { init, submiting, loading, success, failure }
enum VStatus { valid, invalid }

abstract class FormItem<T> {
  const FormItem(this.value);

  final T value;

  List<Validator> get validators;

  bool get isValid => validators.every((v) => v.isValid(value));

  String? get error =>
      validators.firstWhereOrNull((v) => !v.isValid(value))?.errorText;
}

class FormStatus {
  const FormStatus({
    required this.status,
    this.message,
  });

  static const FormStatus init = FormStatus(status: FStatus.init);
  static const FormStatus submiting = FormStatus(status: FStatus.submiting);
  static const FormStatus loading = FormStatus(status: FStatus.loading);

  const FormStatus.success([String message = ''])
      : this(status: FStatus.success, message: message);

  const FormStatus.failure([String message = ''])
      : this(status: FStatus.failure, message: message);

  final FStatus status;
  final String? message;
}

mixin ValidationMixin {
  VStatus validate([List<FormItem>? i]) =>
      (i ?? inputs).every((item) => item.isValid)
          ? VStatus.valid
          : VStatus.invalid;

  List<FormItem> get inputs;
}

extension ValidationStatusExtension on VStatus {
  bool get isValid => this == VStatus.valid;
  bool get isInvalid => this == VStatus.invalid;
}

extension FormStatusExtension on FormStatus {
  bool get isInit => status == FStatus.init;
  bool get isSubmiting => status == FStatus.submiting;
  bool get isLoading => status == FStatus.loading;
  bool get isSuccess => status == FStatus.success;
  bool get isFailure => status == FStatus.failure;
}
