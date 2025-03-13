import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';

class BluetoothProvider extends ChangeNotifier {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothDevice? connectedDevice;
  BluetoothConnection? connection;
  bool isConnecting = false;
  bool isConnected = false;
  String receivedData = '';
  String _buffer = ''; // Buffer to store incoming data fragments

  Future<bool> connectToFirstBondedDevice() async {
    try {
      List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
      if (bondedDevices.isNotEmpty) {
        return await connectToDevice(bondedDevices.first);
      }
    } catch (e) {
      debugPrint('Error getting bonded devices: $e');
    }
    return false;
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    isConnecting = true;
    notifyListeners();

    try {
      connection = await BluetoothConnection.toAddress(device.address);
      connectedDevice = device;
      isConnected = true;
      notifyListeners();

      connection!.input?.listen((Uint8List data) {
        _handleIncomingData(String.fromCharCodes(data));
      }).onDone(() {
        disconnect();
      });

      isConnecting = false;
      notifyListeners();
      return true; // Connection successful
    } catch (e) {
      isConnected = false;
      connection = null;
      isConnecting = false;
      notifyListeners();
      return false; // Connection failed
    }
  }

  void _handleIncomingData(String newData) {
    _buffer += newData; // Append new data to buffer

    // Process only when a full message is received (assuming messages end with '\n')
    while (_buffer.contains('\n')) {
      int newlineIndex = _buffer.indexOf('\n');
      String completeMessage = _buffer.substring(0, newlineIndex).trim();
      _buffer = _buffer.substring(newlineIndex + 1); // Remove processed message

      if (completeMessage.isNotEmpty) {
        receivedData = completeMessage.trim();  // Trim any extra spaces
        debugPrint('Received data: $receivedData');  // Debugging line to verify
        notifyListeners();
      }
    }
  }

  String getTranslatedGesture() {
  switch (receivedData.toLowerCase()) {  // This converts the received data to lowercase before matching
    case "straight.":
      return "Open Hand";
    case "slightly bent.":
      return "Hello!";
    case "moderate bend.":
      return "Goodbye!";
    case "fully bent.":
      return "Be Careful!";
    default:
      return "Unknown Gesture";
  }
}


  Future<void> disconnect() async {
    connection?.close();
    connection = null;
    connectedDevice = null;
    isConnected = false;
    receivedData = '';
    _buffer = ''; // Clear buffer on disconnect
    notifyListeners();
  }
}
