import 'package:flutter/foundation.dart';

import '../core/utils/audio_manager.dart';

/// Exposes independent music and SFX mute controls.
class AudioProvider extends ChangeNotifier {
  final AudioManager _audioManager;

  AudioProvider(this._audioManager);

  /// Returns whether background music is muted.
  bool get musicMuted => _audioManager.musicMuted;

  /// Returns whether sound effects are muted.
  bool get sfxMuted => _audioManager.sfxMuted;

  /// Returns whether touch haptics are enabled.
  bool get hapticsEnabled => _audioManager.hapticsEnabled;

  /// Toggles music playback.
  void toggleMusic() {
    _audioManager.setMusicMuted(muted: !musicMuted);
    notifyListeners();
  }

  /// Toggles sound effects playback.
  void toggleSfx() {
    _audioManager.setSfxMuted(muted: !sfxMuted);
    notifyListeners();
  }

  /// Toggles touch haptic feedback.
  void toggleHaptics() {
    _audioManager.setHapticsEnabled(enabled: !hapticsEnabled);
    notifyListeners();
  }

  /// Starts background music.
  Future<void> startMusic() async {
    await _audioManager.playMusic();
  }
}
