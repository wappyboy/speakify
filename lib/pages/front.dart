import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:speakify_app/providers/bluetooth_provider.dart';
import 'package:speakify_app/widgets/gesture_display.dart';
import 'package:audioplayers/audioplayers.dart';

class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer(); // New audio player instance
  String? _lastSpokenGesture;

  @override
  void initState() {
    super.initState();

    // Set default TTS settings
    flutterTts.setLanguage('en-US');
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);

    // Connect to first bonded device manually
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<BluetoothProvider>(context, listen: false)
          .connectToFirstBondedDevice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, child) {
        final currentGesture = bluetoothProvider.getTranslatedGesture();

        // Speak or play sound cue for "Unknown Gesture"
        if (bluetoothProvider.isGestureRecognitionActive &&
            currentGesture.isNotEmpty &&
            currentGesture != _lastSpokenGesture) {
          _lastSpokenGesture = currentGesture;

          if (currentGesture == "Unknown Gesture") {
            audioPlayer.play(AssetSource('sounds/error_beep.mp3'));
          } else {
            flutterTts.speak(currentGesture);
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'SPEAKIFY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            centerTitle: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
          drawer: Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: const Text('Bluetooth Scan'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/scan');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('About'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/about');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Help and Support'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/help');
                        },
                      ),
                    ],
                  ),
                ),
                Consumer<BluetoothProvider>(
                  builder: (context, bluetoothProvider, child) {
                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            bluetoothProvider.isConnected ? Icons.circle : Icons.circle,
                            color: bluetoothProvider.isConnected ? Colors.green : Colors.red,
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            bluetoothProvider.isConnected
                                ? 'Connected to ${bluetoothProvider.connectedDevice?.name ?? "Unknown"}'
                                : 'Bluetooth is Disconnected',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          body: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: bluetoothProvider.isGestureRecognitionActive
                          ? const GestureDisplay(key: ValueKey('gesture'))
                          : const Text(
                              'Press Start to begin recognizing gestures!',
                              key: ValueKey('placeholder'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: bluetoothProvider.isGestureRecognitionActive
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        bluetoothProvider.toggleGestureRecognition();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Text(
                            bluetoothProvider.isGestureRecognitionActive
                                ? 'Stop Gesture Recognition'
                                : 'Start Gesture Recognition',
                            key: ValueKey<bool>(bluetoothProvider.isGestureRecognitionActive),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    Provider.of<BluetoothProvider>(context, listen: false).disconnect();
    super.dispose();
  }
}