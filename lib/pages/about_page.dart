import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Speakify by the Dream Team',
                      style: theme.headlineSmall,
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'A thesis project designed to aid the communication of deaf individuals through a smart glove and Flutter-based mobile interface.',
                      style: theme.bodyLarge,
                    ),
                    const SizedBox(height: 32),

                    // Group Members
                    Text('Group Members:', style: theme.titleLarge),
                    const SizedBox(height: 12),
                    const Text('• Aldrin Arat'),
                    const Text('• Gerwin Delaza'),
                    const Text('• Ralph Eco'),
                    const Text('• Judy Anne Lopez'),
                    const Text('• Lester Mark Ortega'),
                    const Text('• Jarren Red Sanchez'),
                    const SizedBox(height: 32),

                    // Other Info
                    Text(
                      'This app was developed by a passionate team of students dedicated to building assistive technology that makes a difference.',
                      style: theme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('This is our Thesis Project, in cooperation with Asian Institute of Computer Studies-Bicutan Branch.', style: theme.bodyLarge),
                    const SizedBox(height: 8),
                    Text('Version: 1.0', style: theme.bodyLarge),
                    const SizedBox(height: 32),

                    // Acknowledgements
                    Text('Acknowledgements:', style: theme.titleLarge),
                    const SizedBox(height: 12),
                    Text(
                      'Thanks to our school, our instructors, our families, friends, and loved ones for their inspiration and support.',
                      style: theme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
