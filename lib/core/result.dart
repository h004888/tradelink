import 'failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is ResultSuccess<T>;
  bool get isFailure => this is FailureResult<T>;
}

class ResultSuccess<T> extends Result<T> {
  final T data;
  const ResultSuccess(this.data);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);
}
