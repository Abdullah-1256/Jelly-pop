import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/player_progress.dart';
import '../constants/app_strings.dart';

/// Persists player progress locally with SharedPreferences.
class SaveManager {
  final SharedPreferences _preferences;

  const SaveManager._(this._preferences);

  /// Creates a save manager with a ready SharedPreferences instance.
  static Future<SaveManager> create() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return SaveManager._(preferences);
  }

  /// Writes the complete progress object to local storage.
  Future<void> saveProgress(PlayerProgress progress) async {
    final String encoded = jsonEncode(progress.toJson());
    await _preferences.setString(AppStrings.progressKey, encoded);
  }

  /// Loads saved progress, or creates a fresh profile when none exists.
  PlayerProgress loadProgress() {
    final String? encoded = _preferences.getString(AppStrings.progressKey);
    if (encoded == null) {
      return const PlayerProgress();
    }
    final Map<String, Object?> json =
        jsonDecode(encoded) as Map<String, Object?>;
    return PlayerProgress.fromJson(json);
  }

  /// Removes all saved progress and returns the app to level one.
  Future<void> resetProgress() async {
    await _preferences.remove(AppStrings.progressKey);
  }
}
