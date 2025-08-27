import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _isMutedKey = 'isMuted';
  static const String _muteDurationKey = 'muteDuration';
  static const String _vibrationEnabledKey = 'vibrationEnabled';
  static const String _notificationSoundKey = 'notificationSound';
  static const String _profileImagePathKey = 'profileImagePath';

  // Initialize SharedPreferences
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Save login status
  static Future<void> setLoginStatus(bool isLoggedIn) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  // Retrieve login status
  static Future<bool> getLoginStatus() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Save mute status
  static Future<void> setMuteStatus(bool isMuted) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_isMutedKey, isMuted);
  }

  // Retrieve mute status
  static Future<bool> getMuteStatus() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_isMutedKey) ?? false;
  }

  // Save mute duration (hours, -1 for forever)
  static Future<void> setMuteDuration(int duration) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_muteDurationKey, duration);
  }

  // Retrieve mute duration
  static Future<int> getMuteDuration() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_muteDurationKey) ?? 0;
  }

  // Save vibration enabled status
  static Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_vibrationEnabledKey, enabled);
  }

  // Retrieve vibration enabled status
  static Future<bool> getVibrationEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  // Save notification sound
  static Future<void> setNotificationSound(String sound) async {
    final prefs = await _getPrefs();
    await prefs.setString(_notificationSoundKey, sound);
  }

  // Retrieve notification sound
  static Future<String> getNotificationSound() async {
    final prefs = await _getPrefs();
    return prefs.getString(_notificationSoundKey) ?? 'default';
  }

  // Save profile image path
  static Future<void> setProfileImagePath(String path) async {
    final prefs = await _getPrefs();
    await prefs.setString(_profileImagePathKey, path);
  }

  // Retrieve profile image path
  static Future<String?> getProfileImagePath() async {
    final prefs = await _getPrefs();
    return prefs.getString(_profileImagePathKey);
  }

  // Clear profile image path
  static Future<void> clearProfileImagePath() async {
    final prefs = await _getPrefs();
    await prefs.remove(_profileImagePathKey);
  }

  // Clear preferences on logout
  static Future<void> clearPreferences() async {
    final prefs = await _getPrefs();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_isMutedKey);
    await prefs.remove(_muteDurationKey);
    await prefs.remove(_vibrationEnabledKey);
    await prefs.remove(_notificationSoundKey);
    await prefs.remove(_profileImagePathKey);
  }
}