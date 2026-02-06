abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException(String message) : super(message);
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message);
}

class CacheException extends AppException {
  CacheException(String message) : super(message);
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}
