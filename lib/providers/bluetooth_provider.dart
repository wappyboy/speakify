import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import '../utils/gesture_map.dart';

class BluetoothProvider extends ChangeNotifier {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothDevice? connectedDevice;
  BluetoothConnection? connection;
  bool isConnecting = false;
  bool isConnected = false;
  bool isGestureRecognitionActive = false;
  String receivedData = '';
  String _buffer = '';

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
      return true;
    } catch (e) {
      isConnected = false;
      connection = null;
      isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  void toggleGestureRecognition() {
    isGestureRecognitionActive = !isGestureRecognitionActive;
    notifyListeners();
  }

  void _handleIncomingData(String newData) {
    if (!isGestureRecognitionActive) return;
    _buffer += newData;

    while (_buffer.contains('\n')) {
      int newlineIndex = _buffer.indexOf('\n');
      String completeMessage = _buffer.substring(0, newlineIndex).trim();
      _buffer = _buffer.substring(newlineIndex + 1);

      if (completeMessage.isNotEmpty) {
        receivedData = completeMessage;
        debugPrint('Received data: $receivedData');
        notifyListeners();
      }
    }
  }

  String getTranslatedGesture() {
  try {
    List<String> fingerStates = receivedData.split(' ');
    if (fingerStates.length < 3 || !fingerStates.every((s) => s.contains(':'))) {
      return "Unknown Gesture";
    }

    String finger1 = fingerStates[0].split(':')[1].trim().toLowerCase();
    String finger2 = fingerStates[1].split(':')[1].trim().toLowerCase();
    String finger3 = fingerStates[2].split(':')[1].trim().toLowerCase();

    debugPrint('Finger1: $finger1, Finger2: $finger2, Finger3: $finger3');

    String key = [finger1, finger2, finger3].join("_");
    return gestureMap[key] ?? "Unknown Gesture";
  } catch (e) {
    return "Unknown Gesture";
  }
}


  Future<void> disconnect() async {
    connection?.close();
    connection = null;
    connectedDevice = null;
    isConnected = false;
    receivedData = '';
    _buffer = '';
    notifyListeners();
  }
}