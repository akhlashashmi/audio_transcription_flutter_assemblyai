/// Custom exceptions for better error handling
class TranscriptionException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  TranscriptionException(this.message, {this.code, this.details});

  @override
  String toString() => 'TranscriptionException: $message (Code: $code)';
}
