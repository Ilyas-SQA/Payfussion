import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // Fetch the SharedPreferences instance asynchronously
  Future<SharedPreferences> _getPreferences() async {
    return await SharedPreferences.getInstance();
  }

  Future<bool> setValue(String key, String value) async {
    final prefs = await _getPreferences();
    return prefs.setString(key, value);
  }

  Future<String?> readValue(String key) async {
    final prefs = await _getPreferences();
    return prefs.getString(key);
  }

  Future<bool> clearValue(String key) async {
    final prefs = await _getPreferences();
    return prefs.remove(key);
  }
}
