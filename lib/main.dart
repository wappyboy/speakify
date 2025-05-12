import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakify_app/theme.dart';
import 'package:speakify_app/pages/scan.dart';
import 'package:speakify_app/pages/settings.dart';
import 'package:speakify_app/providers/theme_provider.dart';
import 'package:speakify_app/providers/bluetooth_provider.dart';
import 'package:speakify_app/providers/tts_provider.dart';
import 'package:speakify_app/providers/custom_gesture_provider.dart';
import 'package:speakify_app/pages/front.dart';
import 'package:speakify_app/pages/about_page.dart';
import 'package:speakify_app/pages/help_page.dart';
import 'package:speakify_app/pages/custom_gestures.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Required for SharedPreferences
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => TtsProvider()),
        ChangeNotifierProvider(create: (_) => CustomGestureProvider()),
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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const FrontPage(),
      routes: {
        '/scan': (context) => const ScanPage(),
        '/settings': (context) => const SettingsPage(),
        '/custom_gestures': (context) => const CustomGesturesScreen(),
        '/about': (context) => const AboutPage(),
        '/help': (context) => const HelpPage(),
      },
    );
  }
}