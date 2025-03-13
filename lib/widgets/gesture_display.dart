import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakify_app/providers/bluetooth_provider.dart';

class GestureDisplay extends StatelessWidget {
  const GestureDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, child) {
        return Card(
          elevation: 4, // Adds a slight shadow for a modern look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Gesture: ${bluetoothProvider.getTranslatedGesture()}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
