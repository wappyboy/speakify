import 'package:flutter/material.dart';

class GestureDisplay extends StatelessWidget {
  final String gesture;

  const GestureDisplay({super.key, required this.gesture});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        'Gesture: $gesture',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
