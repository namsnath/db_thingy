import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:indent/indent.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '/core/services/shared_prefs_service.dart';

/// Model that holds the state for [DirectorySelectPage].
class DirectorySelectViewModel with ChangeNotifier {
  final log = Logger('DirectorySelectViewModel');
  late SharedPrefsService _prefsService;

  /// Initialize the model with a [SharedPrefsService] from GetIt.
  ///
  /// Optionally, pass in a custom [prefsService].
  DirectorySelectViewModel({SharedPrefsService? prefsService}) {
    this._prefsService = prefsService ?? GetIt.I.get<SharedPrefsService>();
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

  String _selectedDBPath = '';
  String get selectedDBPath => _selectedDBPath;

  Database? _selectedDB;
  Database? get selectedDB => _selectedDB;

  List<String> _tables = [];
  List<String> get tables => _tables;

  List<Map<String, dynamic>>? _relations;

  /// A list of foreign key relations in the database.
  List<Map<String, dynamic>>? get relations => _relations;

  /// Queries SQLite to find Foriegn Key relations in the schema.
  populateFKRelations() async {
    final query = '''
      SELECT
          m.name as fromTable
          , p.*
      FROM
          sqlite_master m
          -- join on places where local and fk table don't match
          -- If we need self-joins, need equality condition as well
          JOIN pragma_foreign_key_list(m.name) p ON m.name != p."table"
      WHERE m.type = 'table'
      ORDER BY m.name;
    '''
        .unindent();

    try {
      final relations = await _selectedDB?.rawQuery(query) ?? [];
      _relations = relations;

      notifyListeners();
    } catch (e) {
      log.severe(e);
    }
  }

  /// Queries `sqlite_master` to find the tables in the DB.
  populateTablesList() async {
    try {
      final tableNamesQuery = await _selectedDB?.query(
            'sqlite_master',
            where: 'type = ?',
            whereArgs: ['table'],
          ) ??
          [];

      final tableNames = tableNamesQuery
          .map((row) => row['name'] as String)
          .toList(growable: false);

      _tables = tableNames;

      notifyListeners();
    } catch (e) {
      log.severe(e);
    }
  }

  /// Updates the selected DB and path given a [path].
  ///
  /// Also calls other functions that populate tables and relations list.
  selectDB(String path) async {
    if (path == _selectedDBPath) {
      return;
    }

    try {
      final newDB = await openDatabase(path);

      // If a DB object is present, close it.
      if (_selectedDB != null) {
        log.info('Closing DB ($_selectedDBPath)');
        await _selectedDB!.close();

        _tables = [];
        _relations = [];
      }

      _selectedDBPath = path;
      _selectedDB = newDB;

      // Calling notifyListeners() here since populateFKRelations() could fail and is async.
      notifyListeners();

      populateTablesList();
      populateFKRelations();
    } catch (e) {
      log.severe(e);
    }
  }
}
