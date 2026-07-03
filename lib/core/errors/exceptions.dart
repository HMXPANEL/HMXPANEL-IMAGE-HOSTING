class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  AppException(this.message, {this.code, this.stackTrace});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class AuthException extends AppException {
  AuthException(super.message, {super.code, super.stackTrace});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.stackTrace});
}

class UploadException extends AppException {
  UploadException(super.message, {super.code, super.stackTrace});
}


firebaseExceptionHandler({
  required String message,
  String? code,
}) {
  switch (code) {
    case 'invalid-email':
      return AuthException('Invalid email format', code: code);
    case 'user-disabled':
      return AuthException('Account disabled', code: code);
    case 'user-not-found':
      return AuthException('No account found', code: code);
    case 'wrong-password':
      return AuthException('Wrong password', code: code);
    case 'email-already-in-use':
      return AuthException('Email already registered', code: code);
    case 'weak-password':
      return AuthException('Password too weak', code: code);
    case 'network-request-failed':
      return NetworkException('Network error', code: code);
    default:
      return AppException(message, code: code);
  }
}
