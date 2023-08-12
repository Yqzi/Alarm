import 'package:adhan_dart/adhan_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = _preferences ?? await SharedPreferences.getInstance();
  }

  void save(String key, String value) {
    _preferences?.setString(key, value);
  }

  String? load(String key) {
    return _preferences?.getString(key);
  }

  void saveCoord(Coordinates c) {
    _preferences?.setDouble("lat", c.latitude);
    _preferences?.setDouble("long", c.longitude);
  }

  Coordinates? loadCoord() {
    try {
      return Coordinates(
        _preferences!.getDouble("lat")!,
        _preferences!.getDouble("long")!,
      );
    } catch (_) {
      return null;
    }
  }
}
