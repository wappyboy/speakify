import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakify_app/theme.dart';
import 'package:speakify_app/pages/scan.dart';
import 'package:speakify_app/pages/settings.dart';
import 'package:speakify_app/providers/theme_provider.dart';
import 'package:speakify_app/providers/bluetooth_provider.dart';
import 'package:speakify_app/providers/tts_provider.dart';
import 'package:speakify_app/pages/front.dart';
import 'package:speakify_app/pages/about_page.dart';
import 'package:speakify_app/pages/help_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => TtsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Speakify',
      debugShowCheckedModeBanner: false, // Keeps app looking clean
      theme: AppTheme.lightTheme, // ✅ Fixed reference
      darkTheme: AppTheme.darkTheme, // ✅ Fixed reference
      themeMode: themeProvider.themeMode, // ✅ Controls dark/light mode
      home: const FrontPage(), // ✅ Ensures front page loads correctly
      routes: { // ✅ Add this
        '/scan': (context) => const ScanPage(),
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
        '/help': (context) => const HelpPage(),
      },
    );
  }
}
