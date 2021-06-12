import 'package:db_thingy/core/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsService with ChangeNotifier {
  late SharedPrefsService prefsService;

  SettingsService({SharedPrefsService? prefsService}) {
    this.prefsService = prefsService ?? GetIt.I.get<SharedPrefsService>();
  }
}