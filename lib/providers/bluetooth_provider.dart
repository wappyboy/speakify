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

  List<Map<String, String>>? _customGestures;

  // Set custom gestures (called from the UI)
  void setCustomGestures(List<Map<String, String>> gestures) {
    _customGestures = gestures;
    notifyListeners();
  }

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
    if (fingerStates.length != 5 || !fingerStates.every((s) => s.contains(':'))) {
      return "Unknown Gesture";
    }

    Map<String, String> fingerMap = {};
    for (var state in fingerStates) {
      var parts = state.split(':');
      if (parts.length == 2) {
        fingerMap[parts[0].trim().toLowerCase()] = parts[1].trim().toLowerCase();
      }
    }

    List<String> orderedStates = [
      fingerMap['thumb'] ?? 'unknown',
      fingerMap['pointing'] ?? 'unknown',
      fingerMap['middle'] ?? 'unknown',
      fingerMap['ring'] ?? 'unknown',
      fingerMap['pinky'] ?? 'unknown',
    ];

    String key = orderedStates.join("_");
    debugPrint('Gesture key: $key');

    // 1. Check custom gestures first
    if (_customGestures != null) {
      for (final gesture in _customGestures!) {
        if (gesture['pattern'] == key) {
          debugPrint('Matched custom gesture: ${gesture['label']}');
          return gesture['label'] ?? "Unknown Gesture";
        }
      }
    }

    // 2. Fallback to default gestures
    final defaultLabel = gestureMap[key];
    if (defaultLabel != null) {
      debugPrint('Matched default gesture: $defaultLabel');
      return defaultLabel;
    }

    // 3. No match found
    return "Unknown Gesture";
  } catch (e) {
    debugPrint('Error in getTranslatedGesture: $e');
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