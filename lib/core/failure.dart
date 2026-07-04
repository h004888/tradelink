sealed class Failure {
  final String message;
  const Failure({required this.message});
}

class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure({required super.message, this.statusCode});

  @override
  String toString() => 'NetworkFailure: $message (status: $statusCode)';
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});

  @override
  String toString() => 'AuthFailure: $message';
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure({required super.message, this.fieldErrors});

  @override
  String toString() => 'ValidationFailure: $message';
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});

  @override
  String toString() => 'NotFoundFailure: $message';
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});

  @override
  String toString() => 'PermissionFailure: $message';
}

class UnknownFailure extends Failure {
  final Object? originalError;
  const UnknownFailure({required super.message, this.originalError});

  @override
  String toString() => 'UnknownFailure: $message';
}
