import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  late final SharedPreferences _prefs;
  SharedPreferences get prefs => _prefs;

  Future<SharedPrefsService> init() async {
    _prefs = await SharedPreferences.getInstance();

    return this;
  }

  Future<bool> setSharedPref<T>(String key, T value) async {
    if (value is bool) {
      return await _prefs.setBool(key, value);
    }

    if (value is double) {
      return await _prefs.setDouble(key, value);
    }

    if (value is int) {
      return await _prefs.setInt(key, value);
    }

    if (value is String) {
      return await _prefs.setString(key, value);
    }

    if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    }

    return Future.value(false);
  }
}
