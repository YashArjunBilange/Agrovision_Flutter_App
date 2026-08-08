import 'package:dio/dio.dart';

class Failure {
  final String message;
  final int? statusCode;
  final dynamic error;

  const Failure({
    required this.message,
    this.statusCode,
    this.error,
  });

  factory Failure.fromException(dynamic exception) {
    if (exception is Failure) {
      return exception;
    }

    if (exception is DioException) {
      final statusCode = exception.response?.statusCode;
      final responseData = exception.response?.data;

      String message = 'An unexpected error occurred. Please try again.';

      if (responseData is Map && responseData.containsKey('detail')) {
        final detail = responseData['detail'];
        if (detail is String) {
          message = detail;
        } else if (detail is List && detail.isNotEmpty) {
          message = detail.map((e) => e['msg'] ?? e.toString()).join(', ');
        }
      } else if (exception.type == DioExceptionType.connectionTimeout ||
          exception.type == DioExceptionType.sendTimeout ||
          exception.type == DioExceptionType.receiveTimeout) {
        return const NetworkFailure(
          message: 'Connection timed out. Please check your network connection.',
        );
      } else if (exception.type == DioExceptionType.connectionError) {
        return const NetworkFailure(
          message: 'Cannot reach server. Please check your internet connection.',
        );
      }

      if (statusCode == 401 || statusCode == 403) {
        return AuthFailure(message: message, statusCode: statusCode);
      } else if (statusCode != null && statusCode >= 500) {
        return ServerFailure(message: 'Server error: $message', statusCode: statusCode);
      }

      return Failure(message: message, statusCode: statusCode, error: exception);
    }

    return Failure(message: exception.toString(), error: exception);
  }

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Unable to connect to server. Please check your internet connection.',
    super.statusCode,
    super.error,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
    super.error,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode = 401,
    super.error,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load cached local data.',
    super.statusCode,
    super.error,
  });
}
