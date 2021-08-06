enum Status { init, loading, success, failure }

class FormItem<T> {
  const FormItem(this.value);

  final T value;
}

class FormStatus {
  const FormStatus._(this.status, [this.error = '']);
  const FormStatus.init() : this._(Status.init);
  const FormStatus.loading() : this._(Status.loading);
  const FormStatus.success() : this._(Status.success);
  const FormStatus.failure(String error) : this._(Status.failure, error);

  final Status status;
  final String error;

  bool get isLoading => this.status == Status.loading;
  bool get isSuccess => this.status == Status.success;
  bool get isFailure => this.status == Status.failure;
}
