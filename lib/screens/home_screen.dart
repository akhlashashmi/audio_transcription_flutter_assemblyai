import 'package:audio_transcription_with_assemblyai/screens/file_transcription.dart';
import 'package:audio_transcription_with_assemblyai/screens/url_transcription.dart';
import 'package:audio_transcription_with_assemblyai/widgets/option_tile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            expandedHeight: 300,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              centerTitle: true,
              title: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Audio Transcription',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.surface,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    // Spacing above the card
                    bottom: 65,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Icon(
                            Icons.graphic_eq,
                            color: Theme.of(context).colorScheme.primary,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                              // color: Theme.of(context)
                              //     .colorScheme
                              //     .surface
                              //     .withOpacity(0.8),
                              // borderRadius: BorderRadius.circular(16),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.black.withOpacity(0.15),
                              //     blurRadius: 8,
                              //     offset: const Offset(0, 4),
                              //   ),
                              // ],
                              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Welcome to Audio Transcription',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Choose a method below to convert your audio into text effortlessly.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.8),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Convert Audio to Text',
                  //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  // ),
                  // const SizedBox(height: 12),
                  // Text(
                  //   'Choose your preferred method to transcribe audio into text',
                  //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  //         color: Theme.of(context).colorScheme.onSurfaceVariant,
                  //       ),
                  // ),
                  // const SizedBox(height: 32),
                  OptionCard(
                    icon: Icons.upload_file,
                    title: 'Upload Audio File',
                    description: 'Select an audio file from your device',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FileTranscriptionScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OptionCard(
                    icon: Icons.link,
                    title: 'Enter Audio URL',
                    description: 'Transcribe audio from a web link',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const URLTranscriptionScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
