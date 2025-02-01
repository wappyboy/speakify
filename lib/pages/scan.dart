import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final Set<BluetoothDevice> devicesSet =
      {}; // Use a Set to ensure unique devices
  bool isScanning = false; // Indicates if scanning is in progress

  // Method to start scanning for Bluetooth devices
  void _startBluetoothScan() {
    setState(() {
      isScanning = true;
      devicesSet.clear();
    });

    // Start scanning
    FlutterBluePlus.startScan();

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        setState(() {
          devicesSet.add(result.device);
        });
      }
    });

    // Stop scanning after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      FlutterBluePlus.stopScan();
      setState(() {
        isScanning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Scanner'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? null : _startBluetoothScan,
            child: isScanning
                ? const Text('Scanning...')
                : const Text('Start Scan'),
          ),
          Expanded(
            child: devicesSet.isEmpty
                ? const Center(child: Text('No devices found'))
                : ListView.builder(
                    itemCount: devicesSet.length,
                    itemBuilder: (context, index) {
                      var device = devicesSet.elementAt(index);
                      return ListTile(
                        title: Text(device.name.isNotEmpty
                            ? device.name
                            : 'Unknown device'),
                        subtitle: Text(device.id.toString()),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
