import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static void save(String key, String value) {
    _preferences.setString(key, value);
  }

  static String? load(String key) {
    return _preferences.getString(key);
  }
}
