import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakify_app/providers/theme_provider.dart';
import 'package:speakify_app/providers/tts_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Language code to readable label
  static final Map<String, String> _languageMap = {
    'en-US': 'English (US)',
    'en-GB': 'English (UK)',
    'es-ES': 'Spanish (Spain)',
    'fr-FR': 'French (France)',
    'de-DE': 'German (Germany)',
    'it-IT': 'Italian',
    'ja-JP': 'Japanese',
    'ko-KR': 'Korean',
    'zh-CN': 'Chinese (Simplified)',
    'hi-IN': 'Hindi',
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ttsProvider = Provider.of<TtsProvider>(context);
    final currentLang = ttsProvider.language;

    // Build dropdown items with fallback if currentLang is not listed
    final dropdownItems = [
      if (!_languageMap.containsKey(currentLang))
        DropdownMenuItem(
          value: currentLang,
          child: Text('$currentLang (Unknown Language)'),
        ),
      ..._languageMap.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Text-to-Speech Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),
            const Text('Language'),
            DropdownButton<String>(
              value: currentLang,
              isExpanded: true,
              items: dropdownItems,
              onChanged: (value) {
                if (value != null) ttsProvider.setLanguage(value);
              },
            ),

            const SizedBox(height: 16),
            const Text('Pitch'),
            Slider(
              value: ttsProvider.pitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: ttsProvider.pitch.toStringAsFixed(2),
              onChanged: (value) {
                ttsProvider.setPitch(value);
              },
            ),

            const SizedBox(height: 16),
            const Text('Speech Rate'),
            Slider(
              value: ttsProvider.speechRate,
              min: 0.1,
              max: 1.0,
              divisions: 18,
              label: ttsProvider.speechRate.toStringAsFixed(2),
              onChanged: (value) {
                ttsProvider.setSpeechRate(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
