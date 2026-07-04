sealed class UiState<T> {
  const UiState();
}

class Idle<T> extends UiState<T> {
  const Idle();
}

class Loading<T> extends UiState<T> {
  const Loading();
}

class Success<T> extends UiState<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends UiState<T> {
  final String message;
  final bool retryable;
  const Error({required this.message, this.retryable = false});
}
