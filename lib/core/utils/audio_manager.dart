import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../constants/app_strings.dart';

/// Handles all local music and sound-effect playback.
class AudioManager {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Map<String, AudioPlayer> _sfxPlayers = <String, AudioPlayer>{};
  bool _musicMuted = false;
  bool _sfxMuted = false;
  bool _hapticsEnabled = true;

  /// Prepares reusable audio players for every bundled sound.
  Future<void> preloadAll() async {
    for (final String asset in _sfxAssets) {
      _sfxPlayers[asset] = AudioPlayer();
    }
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Plays a one-shot sound effect unless SFX are muted.
  Future<void> playSfx(String asset) async {
    if (_sfxMuted) {
      return;
    }
    try {
      final AudioPlayer player = _sfxPlayers[asset] ?? AudioPlayer();
      _sfxPlayers[asset] = player;
      await player.stop();
      await player.play(AssetSource('audio/$asset'));
    } catch (_) {}
  }

  /// Plays a crisp haptic click when a candy is selected.
  Future<void> playSelectHaptic() async {
    if (!_hapticsEnabled) {
      return;
    }
    await HapticFeedback.selectionClick();
  }

  /// Plays a satisfying haptic thud for successful candy swaps.
  Future<void> playSwapHaptic() async {
    if (!_hapticsEnabled) {
      return;
    }
    await HapticFeedback.mediumImpact();
  }

  /// Plays a strong haptic pop when candies are matched and cleared.
  Future<void> playMatchHaptic() async {
    if (!_hapticsEnabled) {
      return;
    }
    await HapticFeedback.heavyImpact();
  }

  /// Plays an error buzz when a swap is not accepted.
  Future<void> playErrorHaptic() async {
    if (!_hapticsEnabled) {
      return;
    }
    await HapticFeedback.vibrate();
  }

  /// Plays a two-step haptic hit for combos, specials, and boosters.
  Future<void> playComboHaptic() async {
    if (!_hapticsEnabled) {
      return;
    }
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
  }

  /// Starts looped background music unless music is muted.
  Future<void> playMusic() async {
    if (_musicMuted) {
      return;
    }
    try {
      await _musicPlayer.play(AssetSource('audio/${AppStrings.audioMusic}'));
    } catch (_) {}
  }

  /// Stops looped background music.
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  /// Updates the independent music mute flag.
  void setMusicMuted({required bool muted}) {
    _musicMuted = muted;
    if (muted) {
      _musicPlayer.stop();
    } else {
      playMusic();
    }
  }

  /// Updates the independent sound-effect mute flag.
  void setSfxMuted({required bool muted}) {
    _sfxMuted = muted;
  }

  /// Updates whether touch haptics are enabled.
  void setHapticsEnabled({required bool enabled}) {
    _hapticsEnabled = enabled;
  }

  /// Returns whether music playback is muted.
  bool get musicMuted => _musicMuted;

  /// Returns whether sound effects are muted.
  bool get sfxMuted => _sfxMuted;

  /// Returns whether touch haptics are enabled.
  bool get hapticsEnabled => _hapticsEnabled;

  static const List<String> _sfxAssets = <String>[
    AppStrings.audioSwap,
    AppStrings.audioMatch,
    AppStrings.audioCascade,
    AppStrings.audioSpecial,
    AppStrings.audioWin,
    AppStrings.audioLose,
  ];
}
