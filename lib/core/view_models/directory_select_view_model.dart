import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '/core/services/shared_prefs_service.dart';

/// Model that holds the state for [DirectorySelectPage].
class DirectorySelectViewModel with ChangeNotifier {
  final log = Logger('DirectorySelectViewModel');
  late SharedPrefsService _prefsService;

  /// Initialize the model with a [SharedPrefsService] from GetIt.
  ///
  /// Optionally, pass in a custom [prefsService].
  DirectorySelectViewModel({SharedPrefsService? prefsService}) {
    _prefsService = prefsService ?? GetIt.I.get<SharedPrefsService>();
  }

  /// Initializes the class by fetching [selectedDirectory] from shared preferences.
  ///
  /// If a directory is found, populate the list of databases from it using
  /// [populateDBlistFromDirectory()].
  Future<DirectorySelectViewModel> init() async {
    final dir = _prefsService.prefs.getString('selectedDirectory');

    if (dir == null || dir == '') {
      return this;
    }

    setSelectedDirectory(Directory(dir));

    return this;
  }

  Directory? _selectedDirectory;

  /// The currently selected directory to search for databases in.
  Directory? get selectedDirectory => _selectedDirectory;
  setSelectedDirectory(Directory? dir) async {
    // Not checking for null [dir] here. In cases of a null, set empty String
    // in shared prefs.
    log.fine('Setting _selectedDirectory = $dir');
    _selectedDirectory = dir;
    _prefsService.setSharedPref<String>('selectedDirectory', dir?.path ?? '');

    await populateDBListFromDirectory();
    await populateDirAllowed();
    await populateSubDirectories();

    notifyListeners();
  }

  List<bool> _dirAllowed = [];
  List<bool> get dirAllowed => _dirAllowed;

  populateDirAllowed() async {
    if (_selectedDirectory != null && _selectedDirectory!.path != '') {
      final pathComponents = path.split(_selectedDirectory!.path);

      final List<bool> allowed = [];

      for (int i = 0; i < pathComponents.length; i++) {
        final btnPath = path.joinAll(pathComponents.sublist(0, i + 1));
        try {
          await Directory(btnPath).list().toList();
          allowed.add(true);
        } catch (e) {
          allowed.add(false);
        }
      }

      print(allowed);

      _dirAllowed = allowed;

      notifyListeners();
    }
  }

  List<String> _subDirectories = [];
  List<String> get subDirectories => _subDirectories;

  populateSubDirectories() async {
    final List<String> dirList = [];
    if (_selectedDirectory != null) {
      try {
        final list = _selectedDirectory!.list();

        await for (FileSystemEntity f in list) {
          if (f is Directory) {
            dirList.add(f.path);
          }
        }

        log.fine(dirList);
      } catch (e) {
        log.severe(e);
      }

      _subDirectories = dirList;
      notifyListeners();
    }
  }

  List<String> _dbList = [];

  /// A list of database paths in the [selectedDirectory].
  List<String> get dbList => _dbList;

  /// Fetches files in the [selectedDirectory] and filters by extensions.
  ///
  /// Pass [recursive] to find files and directories recursively. This
  /// might encounter permission issues if done in the root directory.
  populateDBListFromDirectory({bool recursive = false}) async {
    final allowedExts = ['db', 'sqlite'];
    final List<String> filteredFilePaths = [];

    final dir = selectedDirectory;

    if (dir != null) {
      try {
        final fileList = dir.list(recursive: recursive);

        await for (FileSystemEntity f in fileList) {
          if (f is File) {
            if (allowedExts.contains(f.path.split('.').last)) {
              filteredFilePaths.add(f.path);
            }
          }
        }

        log.fine(filteredFilePaths);
      } catch (e) {
        log.severe(e);
      }
    }

    _dbList = filteredFilePaths;
    notifyListeners();
  }
}
