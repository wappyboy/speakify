import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome to the Help & Support Page', style: theme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'This page will guide you through using the Speakify app and resolving common issues.',
                  style: theme.bodyMedium,
                ),

                const SizedBox(height: 24),
                Text('Getting Started', style: theme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  '1. Make sure your smart glove is powered on and connected via Bluetooth.\n'
                  '2. Use the Scan page to find and connect to the HC-06 module.\n'
                  '3. Once connected, return to the home page to start recognizing gestures.',
                  style: theme.bodyMedium,
                ),

                const SizedBox(height: 24),
                Text('Using the App', style: theme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  '• The main page shows the translated gesture in text.\n'
                  '• Text-to-speech (TTS) will automatically speak detected gestures.\n'
                  '• You can customize TTS settings like speed and pitch from the Settings page.',
                  style: theme.bodyMedium,
                ),

                const SizedBox(height: 24),
                Text('Troubleshooting', style: theme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  '• If the glove is not connecting, make sure it is paired and powered on.\n'
                  '• Ensure that Bluetooth permissions are enabled in your device settings.\n'
                  '• Restart the app or device if gesture detection seems delayed.',
                  style: theme.bodyMedium,
                ),

                const SizedBox(height: 24),
                Text('Need More Help?', style: theme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'For further support, contact any of our members.\n'
                  'You can reach us via Facebook Messenger.',
                  style: theme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
