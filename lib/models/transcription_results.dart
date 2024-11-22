/// Response model for transcription
class TranscriptionResult {
  final String id;
  final String status;
  final String? text;
  final String? error;

  TranscriptionResult({
    required this.id,
    required this.status,
    this.text,
    this.error,
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      id: json['id'],
      status: json['status'],
      text: json['text'],
      error: json['error'],
    );
  }
}
