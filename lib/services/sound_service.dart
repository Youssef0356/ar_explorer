import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SoundService extends ChangeNotifier {
  static const _vibrationEnabledKey = 'vibration_enabled';
  
  SharedPreferences? _prefs;
  bool _isVibrationEnabled = true;

  SoundService();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isVibrationEnabled = _prefs?.getBool(_vibrationEnabledKey) ?? true;
  }

  bool get isVibrationEnabled => _isVibrationEnabled;

  Future<void> toggleVibration() async {
    _isVibrationEnabled = !_isVibrationEnabled;
    await _prefs?.setBool(_vibrationEnabledKey, _isVibrationEnabled);
    notifyListeners();
  }

  void playTap() {
    if (_isVibrationEnabled) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.lightImpact();
    }
  }

  void playSuccess() {
    if (_isVibrationEnabled) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.mediumImpact();
    }
  }

  void playFailure() {
    if (_isVibrationEnabled) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.heavyImpact();
    }
  }

  void playAchievement() {
    if (_isVibrationEnabled) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.vibrate();
    }
  }
}
