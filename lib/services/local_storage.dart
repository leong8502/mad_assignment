import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _notificationsMutedKey = 'notificationsMuted';
  static const _muteDurationKey = 'muteDuration';
  static const _vibrationEnabledKey = 'vibrationEnabled';
  static const _notificationSoundKey = 'notificationSound';
  static const _isLoggedInKey = 'isLoggedIn';
  static const _userEmailKey = 'userEmail';

  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  Future<SharedPreferences> _getPrefs() async => await SharedPreferences.getInstance();

  Future<void> saveNotificationSettings({
    required bool muted,
    required int muteDuration,
    required bool vibration,
    required String sound,
  }) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_notificationsMutedKey, muted);
    await prefs.setInt(_muteDurationKey, muteDuration);
    await prefs.setBool(_vibrationEnabledKey, vibration);
    await prefs.setString(_notificationSoundKey, sound);
  }

  Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await _getPrefs();
    return {
      'muted': prefs.getBool(_notificationsMutedKey) ?? false,
      'muteDuration': prefs.getInt(_muteDurationKey) ?? 0,
      'vibration': prefs.getBool(_vibrationEnabledKey) ?? true,
      'sound': prefs.getString(_notificationSoundKey) ?? 'sound1',
    };
  }

  Future<void> saveLoginStatus({required bool isLoggedIn, String? userEmail}) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
    if (userEmail != null) {
      await prefs.setString(_userEmailKey, userEmail);
    } else {
      await prefs.remove(_userEmailKey);
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<String?> getUserEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString(_userEmailKey);
  }

  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}