import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class URLTranscriptionScreen extends StatefulWidget {
  const URLTranscriptionScreen({super.key});

  @override
  State<URLTranscriptionScreen> createState() => _URLTranscriptionScreenState();
}

class _URLTranscriptionScreenState extends State<URLTranscriptionScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String? _transcriptionResult;
  String? _error;

  Future<void> _transcribeFromText() async {
    if (_textController.text.isEmpty) {
      setState(() => _error = 'Please enter some text');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _transcriptionResult = null;
    });

    try {
      // Simulate transcription delay for demonstration
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _transcriptionResult = _textController.text.toUpperCase());
    } catch (e) {
      setState(() => _error = 'An error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Text for Transcription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter Text',
                hintText: 'Type your text here...',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _transcribeFromText,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Start Transcription'),
              ),
            ),
            if (_transcriptionResult != null) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transcription Result',
                    style: Theme.of(context).textTheme.titleLarge,
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
                      style: Theme.of(context).textTheme.bodyLarge,
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
