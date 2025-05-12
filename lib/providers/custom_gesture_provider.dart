import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/gesture_map.dart';

class CustomGestureProvider with ChangeNotifier {
  static const _key = 'custom_gestures';
  final int maxCustomGestures = 5;
  List<Map<String, String>> _customGestures = [];

  List<Map<String, String>> get customGestures => _customGestures;

  // Constructor to auto-load gestures on startup
  CustomGestureProvider() {
    loadGestures();
  }

  // Load saved gestures from SharedPreferences
  Future<void> loadGestures() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList(_key);
    if (saved != null) {
      _customGestures = saved
          .map((e) {
            final parts = e.split('|');
            if (parts.length == 2) {
              return {'pattern': parts[0], 'label': parts[1]};
            }
            return null;
          })
          .whereType<Map<String, String>>()
          .toList();
      notifyListeners();
    }
  }

  /// Add a custom gesture if valid.
  /// Returns:
  /// - true: success
  /// - false: failure, with reason accessible via [lastError]
  String? _lastError;
  String? get lastError => _lastError;

  Future<bool> addCustomGesture(String pattern, String label) async {
    if (_customGestures.length >= maxCustomGestures) {
      _lastError = 'You can only save up to $maxCustomGestures custom gestures.';
      return false;
    }

    if (containsPattern(pattern)) {
      _lastError = 'This gesture pattern is already saved as a custom gesture.';
      return false;
    }

    if (gestureMap.containsKey(pattern)) {
      _lastError = 'This gesture pattern already exists in the built-in gestures.';
      return false;
    }

    _customGestures.add({'pattern': pattern, 'label': label});
    await _save();
    _lastError = null;
    notifyListeners();
    return true;
  }

  Future<void> removeCustomGesture(String pattern) async {
    _customGestures.removeWhere((g) => g['pattern'] == pattern);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final saved =
        _customGestures.map((g) => '${g['pattern']}|${g['label']}').toList();
    await prefs.setStringList(_key, saved);
  }

  bool containsPattern(String pattern) {
    return _customGestures.any((g) => g['pattern'] == pattern);
  }

  bool containsLabel(String label) {
    return _customGestures.any((g) => g['label'] == label);
  }

  bool isBuiltInGesture(String pattern) {
    return gestureMap.containsKey(pattern);
  }

  bool isAtLimit() {
    return _customGestures.length >= maxCustomGestures;
  }
}