import 'failure.dart';

sealed class Result<T> {
  const Result();
}

class ResultSuccess<T> extends Result<T> {
  final T data;
  const ResultSuccess(this.data);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);
}
