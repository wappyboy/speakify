import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:speakify_app/widgets/gesture_display.dart'; // Import the gesture display widget
import 'package:flutter_tts/flutter_tts.dart'; // Import Flutter TTS

class FrontPage extends StatefulWidget {
  const FrontPage({Key? key}) : super(key: key);

  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  final FlutterTts flutterTts = FlutterTts();
  List<BluetoothDevice> discoveredDevices = [];
  String gesture = '';
  bool isScanning = false;

  Future<void> startBluetoothScan() async {
    setState(() {
      isScanning = true;
      discoveredDevices.clear();
    });

    try {
      // Check Bluetooth state
      var state = await FlutterBluePlus.adapterState.first;

      if (state != BluetoothAdapterState.on) {
        setState(() {
          isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bluetooth is not available or turned off."),
          ),
        );
        return;
      }

      // Start scanning
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      // Listen for scan results
      flutterBlue.scanResultStream.listen((result) {
        setState(() {
          if (!discoveredDevices.contains(result.device)) {
            discoveredDevices.add(result.device);
          }
        });
      });

      // Simulate recognizing a gesture
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        gesture = 'Sample Gesture';
      });

      // Use text-to-speech to speak the recognized gesture
      await flutterTts.speak(gesture);
    } catch (e) {
      debugPrint("Error during scanning: $e");
    } finally {
      FlutterBluePlus.stopScan();
      setState(() {
        isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(100.0), // Set the height of the AppBar
        child: AppBar(
          backgroundColor:
              const Color(0xFF38b6ff), // Set AppBar background color
          toolbarHeight: 100.0, // Ensure the toolbar height is consistent
          flexibleSpace: Center(
            child: Text(
              'SPEAKIFY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36, // Increase font size for prominence
                fontFamily: 'Roboto', // Use a better font
                color: Colors.white, // Change text color to white
                shadows: const [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black54,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                  Icons.menu), // Keep the hamburger button color as default
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(
              0xFF18375d), // Set the background color of the drawer to navy blue
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF38b6ff),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white, // Set the header text color to white
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bluetooth,
                    color: Colors.white), // Set Bluetooth icon color to white
                title: const Text(
                  'Bluetooth Scan',
                  style: TextStyle(
                      color: Colors.white), // Set button text color to white
                ),
                onTap: () {
                  // Close the drawer
                  Navigator.pop(context);
                  // Navigate to scan page
                  Navigator.pushNamed(context, '/scan');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info,
                    color: Colors.white), // Set About icon color to white
                title: const Text(
                  'About',
                  style: TextStyle(
                      color: Colors.white), // Set button text color to white
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Implement About functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.help,
                    color: Colors.white), // Set Help icon color to white
                title: const Text(
                  'Help and Support',
                  style: TextStyle(
                      color: Colors.white), // Set button text color to white
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Implement Help and Support functionality
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF18375d), // Set the background color for the page
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20.0), // Add some padding
            decoration: BoxDecoration(
              color: Colors
                  .white, // Set the background color of the gesture box to white
              borderRadius: BorderRadius.circular(12.0), // Add rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: const Offset(0, 2),
                  blurRadius: 4.0, // Adjust blur radius
                ),
              ],
            ),
            child: GestureDisplay(
                gesture: gesture), // Display the gesture variable
          ),
        ),
      ),
    );
  }
}

extension on FlutterBluePlus {
  get scanResultStream => null;
}
