import 'dart:io';
import 'package:audio_transcription_with_assemblyai/secret.dart';
import 'package:audio_transcription_with_assemblyai/repositories/transcription_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart'; // Required for Clipboard functionality

class FileTranscriptionScreen extends StatefulWidget {
  const FileTranscriptionScreen({super.key});

  @override
  State<FileTranscriptionScreen> createState() =>
      _FileTranscriptionScreenState();
}

class _FileTranscriptionScreenState extends State<FileTranscriptionScreen> {
  final TranscriptionRepository _repository = TranscriptionRepository(
    apiKey: apiKey,
    client: Client(),
  );

  bool _isLoading = false;
  String? _transcriptionResult;
  String? _error;
  String? _selectedFileName;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
  }

  Future<void> _pickFileAndTranscribe() async {
    if (_isDisposed) return; // Prevent operation if disposed

    setState(() {
      _isLoading = true;
      _error = null;
      _transcriptionResult = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        if (_isDisposed) return;
        setState(() => _selectedFileName = result.files.single.name);

        File audioFile = File(result.files.single.path!);
        final transcription = await _repository.transcribeFile(audioFile);

        if (_isDisposed) return;
        setState(() => _transcriptionResult = transcription.text);
      } else {
        if (_isDisposed) return;
        setState(() => _error = 'No file selected');
      }
    } catch (e) {
      if (_isDisposed) return;
      setState(() => _error = e.toString());
    } finally {
      if (!_isDisposed) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _copyToClipboard() {
    if (_transcriptionResult != null) {
      Clipboard.setData(ClipboardData(text: _transcriptionResult ?? ''));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transcription copied to clipboard!'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Audio File Transcription')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: InkWell(
                onTap: _isLoading ? null : _pickFileAndTranscribe,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFileName ??
                            'Select an audio file to transcribe',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Transcribing...',
                      style: textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
            if (_transcriptionResult != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transcription Result',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _transcriptionResult!,
                      style: textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
