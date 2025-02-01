import 'package:flutter/material.dart';
import 'pages/front.dart'; // Import the front.dart file
import 'pages/scan.dart'; // Import the scan.dart file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Glove Gesture-to-Speech',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: const FrontPage(), // Use FrontPage as the home page
      routes: {
        '/scan': (context) => const ScanPage(), // Define the scan route
      },
    );
  }
}
