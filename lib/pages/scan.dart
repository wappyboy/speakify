import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isScanning = false;
  List<BluetoothDevice> pairedDevices = [];
  List<BluetoothDiscoveryResult> unknownDevices = [];
  StreamSubscription<BluetoothDiscoveryResult>? discoveryStream;

  Future<void> _startBluetoothScan(BluetoothProvider bluetoothProvider) async {
    bool isEnabled = (await bluetoothProvider.bluetooth.isEnabled) ?? false;
    if (!isEnabled) {
      await bluetoothProvider.bluetooth.requestEnable();
    }

    setState(() {
      isScanning = true;
      pairedDevices.clear();
      unknownDevices.clear();
    });

    try {
      List<BluetoothDevice> bondedDevices = await bluetoothProvider.bluetooth.getBondedDevices();
      if (!mounted) return;
      setState(() {
        pairedDevices = bondedDevices;
      });

      discoveryStream = bluetoothProvider.bluetooth.startDiscovery().listen((result) {
        if (!mounted) return;
        bool isAlreadyKnown = pairedDevices.any((d) => d.address == result.device.address) ||
            unknownDevices.any((d) => d.device.address == result.device.address);
        if (!isAlreadyKnown) {
          setState(() {
            unknownDevices.add(result);
          });
        }
      }, onDone: () {
        if (mounted) {
          setState(() {
            isScanning = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _showConnectionDialog(String deviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Connection Successful"),
          content: Text("Connected to $deviceName"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FilledButton.icon(
              onPressed: isScanning ? null : () => _startBluetoothScan(bluetoothProvider),
              icon: isScanning
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search),
              label: isScanning ? const Text('Scanning...') : const Text('Start Scan'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (pairedDevices.isNotEmpty) ...[
                    const ListTile(
                      title: Text(
                        'Available Paired Devices',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...pairedDevices.map(
                      (device) => _buildDeviceTile(device, bluetoothProvider, isPaired: true),
                    ),
                  ],
                  if (unknownDevices.isNotEmpty) ...[
                    const ListTile(
                      title: Text(
                        'Available Unknown Devices',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...unknownDevices.map(
                      (result) => _buildDeviceTile(result.device, bluetoothProvider, isPaired: false),
                    ),
                  ],
                  if (pairedDevices.isEmpty && unknownDevices.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No devices found'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTile(BluetoothDevice device, BluetoothProvider bluetoothProvider, {bool isPaired = false}) {
    String deviceName = isPaired ? (device.name ?? 'Unknown Device') : 'Unknown Device';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: Icon(
          isPaired ? Icons.bluetooth_connected : Icons.bluetooth,
          color: isPaired ? Colors.green : Colors.blue,
        ),
        title: Text(deviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(device.address, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: bluetoothProvider.connectedDevice == device
            ? ElevatedButton.icon(
                onPressed: () {
                  bluetoothProvider.disconnect();
                  _showSnackBar("Disconnected from $deviceName");
                },
                icon: const Icon(Icons.link_off),
                label: const Text('Disconnect'),
              )
            : ElevatedButton.icon(
                onPressed: bluetoothProvider.isConnecting
                    ? null
                    : () async {
                        bool success = await bluetoothProvider.connectToDevice(device);
                        if (success) {
                          _showConnectionDialog(deviceName);
                        } else {
                          _showSnackBar("Unable to connect to $deviceName");
                        }
                      },
                icon: bluetoothProvider.isConnecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.link),
                label: bluetoothProvider.isConnecting ? const Text('Connecting...') : const Text('Connect'),
              ),
      ),
    );
  }
}
