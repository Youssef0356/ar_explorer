import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService extends ChangeNotifier {
  static const _vibrationEnabledKey = 'vibration_enabled';
  static const _soundEnabledKey = 'sound_enabled';
  
  SharedPreferences? _prefs;
  bool _isVibrationEnabled = true;
  bool _isSoundEnabled = true;

  final AudioPlayer _sfxPlayer1 = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _sfxPlayer2 = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _sfxPlayer3 = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  int _currentPlayerIndex = 0;

  SoundService();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isVibrationEnabled = _prefs?.getBool(_vibrationEnabledKey) ?? true;
    _isSoundEnabled = _prefs?.getBool(_soundEnabledKey) ?? true;
  }

  bool get isVibrationEnabled => _isVibrationEnabled;
  bool get isSoundEnabled => _isSoundEnabled;

  Future<void> toggleVibration() async {
    _isVibrationEnabled = !_isVibrationEnabled;
    await _prefs?.setBool(_vibrationEnabledKey, _isVibrationEnabled);
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    await _prefs?.setBool(_soundEnabledKey, _isSoundEnabled);
    notifyListeners();
  }

  // Helper to play multiple sounds overlapping
  Future<void> _playSound(String assetPath) async {
    if (!_isSoundEnabled) return;
    
    _currentPlayerIndex = (_currentPlayerIndex + 1) % 3;
    final player = [ _sfxPlayer1, _sfxPlayer2, _sfxPlayer3 ][_currentPlayerIndex];
    
    // reset if playing
    if (player.state == PlayerState.playing) {
      await player.stop();
    }
    await player.play(AssetSource(assetPath));
  }

  void playTap() {
    if (_isSoundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_isVibrationEnabled) {
      HapticFeedback.vibrate();
    }
  }

  void playSuccess() {
    _playSound('sound effects/correct.wav');
    if (_isVibrationEnabled) {
      HapticFeedback.vibrate();
    }
  }

  void playFailure() {
    _playSound('sound effects/wrong.wav');
    if (_isVibrationEnabled) {
      HapticFeedback.vibrate();
    }
  }

  void playAchievement() {
    if (_isSoundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_isVibrationEnabled) {
      HapticFeedback.vibrate();
    }
  }

  void playModernDiscovery() {
    _playSound('sound effects/ModernDiscovery.wav');
  }

  void playGameTap() {
    _playSound('sound effects/games.wav');
    if (_isVibrationEnabled) {
      HapticFeedback.vibrate();
    }
  }
}
