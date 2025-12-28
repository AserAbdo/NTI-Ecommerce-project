import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving user credentials locally
class CredentialsStorageService {
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';

  /// Save email and password to local storage
  static Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
  }

  /// Get saved email from local storage
  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Get saved password from local storage
  static Future<String?> getSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPassword);
  }

  /// Clear saved credentials
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
  }

  /// Check if credentials are saved
  static Future<bool> hasCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyEmail) && prefs.containsKey(_keyPassword);
  }
}
