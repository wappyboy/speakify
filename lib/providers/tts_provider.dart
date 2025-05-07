import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  double _pitch = 1.0;
  double _speechRate = 0.5;
  String? _language;
  List<String> _languages = [];

  double get pitch => _pitch;
  double get speechRate => _speechRate;
  String? get language => _language;
  List<String> get languages => _languages;

  TtsProvider() {
    _loadSettings();
    _loadLanguages();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _pitch = prefs.getDouble('ttsPitch') ?? 1.0;
    _speechRate = prefs.getDouble('ttsRate') ?? 0.5;
    _language = prefs.getString('ttsLanguage');
    await _applySettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('ttsPitch', _pitch);
    prefs.setDouble('ttsRate', _speechRate);
    if (_language != null) prefs.setString('ttsLanguage', _language!);
  }

  Future<void> _applySettings() async {
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setSpeechRate(_speechRate);
    if (_language != null) {
      await _flutterTts.setLanguage(_language!);
    }
  }

  Future<void> _loadLanguages() async {
    final langs = await _flutterTts.getLanguages;
    _languages = List<String>.from(langs);
    if (_language == null && _languages.isNotEmpty) {
      _language = _languages.first;
      await _applySettings();
    }
    notifyListeners();
  }

  void setPitch(double value) {
    _pitch = value;
    _applySettings();
    _saveSettings();
    notifyListeners();
  }

  void setSpeechRate(double value) {
    _speechRate = value;
    _applySettings();
    _saveSettings();
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    _applySettings();
    _saveSettings();
    notifyListeners();
  }
}