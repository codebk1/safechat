enum FStatus { init, loading, success, failure }

class FormItem<T> {
  const FormItem(this.value);

  final T value;
}

class FormStatus {
  const FormStatus._(this.status, [this.error = '']);
  const FormStatus.init() : this._(FStatus.init);
  const FormStatus.loading() : this._(FStatus.loading);
  const FormStatus.success() : this._(FStatus.success);
  const FormStatus.failure(String error) : this._(FStatus.failure, error);

  final FStatus status;
  final String error;

  bool get isLoading => status == FStatus.loading;
  bool get isSuccess => status == FStatus.success;
  bool get isFailure => status == FStatus.failure;
}
