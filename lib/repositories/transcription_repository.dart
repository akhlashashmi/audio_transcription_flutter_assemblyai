import 'dart:convert';
import 'dart:io';
import 'package:audio_transcription_with_assemblyai/models/transcription_exception.dart';
import 'package:audio_transcription_with_assemblyai/models/transcription_results.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:math' as math;

class TranscriptionRepository {
  final String apiKey;
  final String baseUrl;
  final Duration pollingInterval;
  final int maxRetries;
  final Duration timeout;
  final http.Client _client;

  TranscriptionRepository({
    required this.apiKey,
    this.baseUrl = 'https://api.assemblyai.com/v2',
    this.pollingInterval = const Duration(seconds: 3),
    this.maxRetries = 3,
    this.timeout = const Duration(minutes: 10),
    http.Client? client,
  }) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'authorization': apiKey,
        'content-type': 'application/json',
      };

  /// Transcribe an audio file
  Future<TranscriptionResult> transcribeFile(File file) async {
    try {
      // Upload the file
      final String uploadUrl = await _uploadFile(file);

      // Create transcription job
      return await _createTranscriptionJob(uploadUrl);
    } on http.ClientException catch (e) {
      throw TranscriptionException(
        'Network error during file transcription',
        code: 'NETWORK_ERROR',
        details: e.toString(),
      );
    } catch (e) {
      throw TranscriptionException(
        'Failed to transcribe audio file',
        code: 'TRANSCRIPTION_ERROR',
        details: e.toString(),
      );
    }
  }

  /// Transcribe audio from a URL
  Future<TranscriptionResult> transcribeUrl(String audioUrl) async {
    try {
      return await _createTranscriptionJob(audioUrl);
    } on http.ClientException catch (e) {
      throw TranscriptionException(
        'Network error during URL transcription',
        code: 'NETWORK_ERROR',
        details: e.toString(),
      );
    } catch (e) {
      throw TranscriptionException(
        'Failed to transcribe audio URL',
        code: 'TRANSCRIPTION_ERROR',
        details: e.toString(),
      );
    }
  }

  /// Get status of a transcription job
  Future<TranscriptionResult> getTranscriptionStatus(
      String transcriptionId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/transcript/$transcriptionId'),
        headers: {
          'authorization': apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw TranscriptionException(
          'Failed to get transcription status',
          code: 'STATUS_ERROR',
          details: response.body,
        );
      }

      return TranscriptionResult.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw TranscriptionException(
        'Error checking transcription status',
        code: 'STATUS_CHECK_ERROR',
        details: e.toString(),
      );
    }
  }

  Future<String> _uploadFile(File file) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        final response = await _client.post(
          Uri.parse('$baseUrl/upload'),
          headers: {
            'authorization': apiKey,
          },
          body: file.readAsBytesSync(),
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body)['upload_url'];
        }

        retryCount++;
        await Future.delayed(
          Duration(seconds: math.pow(2, retryCount).toInt()),
        );
      } catch (e) {
        if (retryCount == maxRetries - 1) rethrow;
        retryCount++;
        await Future.delayed(
            Duration(seconds: math.pow(2, retryCount).toInt()));
      }
    }

    throw TranscriptionException(
        'Failed to upload file after $retryCount retries');
  }

  Future<TranscriptionResult> _createTranscriptionJob(String audioUrl) async {
    // Create the transcription job
    final response = await _client.post(
      Uri.parse('$baseUrl/transcript'),
      headers: _headers,
      body: jsonEncode({
        'audio_url': audioUrl,
        'language_detection': true,
      }),
    );

    if (response.statusCode != 200) {
      throw TranscriptionException(
        'Failed to create transcription job',
        code: 'JOB_CREATION_ERROR',
        details: response.body,
      );
    }

    final transcriptionId = jsonDecode(response.body)['id'];

    // Poll for completion
    final completer = Completer<TranscriptionResult>();
    final timer = Timer.periodic(
      pollingInterval,
      (timer) async {
        try {
          final result = await getTranscriptionStatus(transcriptionId);

          if (result.status == 'completed') {
            timer.cancel();
            completer.complete(result);
          } else if (result.status == 'error') {
            timer.cancel();
            completer.completeError(TranscriptionException(
              'Transcription failed',
              code: 'PROCESSING_ERROR',
              details: result.error,
            ));
          }
        } catch (e) {
          timer.cancel();
          completer.completeError(e);
        }
      },
    );

    // Set timeout
    Future.delayed(
      timeout,
      () {
        if (!completer.isCompleted) {
          timer.cancel();
          completer.completeError(
            TranscriptionException(
              'Transcription timeout',
              code: 'TIMEOUT_ERROR',
            ),
          );
        }
      },
    );

    return completer.future;
  }

  void dispose() {
    _client.close();
  }
}
