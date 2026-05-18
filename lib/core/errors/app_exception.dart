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
  const NetworkException([String message = 'No internet connection.'])
      : super(message);
}

class ServerException extends AppException {
  const ServerException(String message, {super.statusCode}) : super(message);
}