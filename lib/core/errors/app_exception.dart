class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'AppException [$statusCode]: $message'
      : 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found.'])
      : super(message, statusCode: 404);
}