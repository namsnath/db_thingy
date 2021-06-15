import 'package:flutter/material.dart';
import 'package:indent/indent.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService with ChangeNotifier {
  final log = Logger('DatabaseService');

  String _selectedDBPath = '';
  String get selectedDBPath => _selectedDBPath;

  Database? _selectedDB;
  Database? get selectedDB => _selectedDB;

  List<String> _tables = [];
  List<String> get tables => _tables;

  List<Map<String, dynamic>> _relations = [];

  /// A list of foreign key relations in the database.
  List<Map<String, dynamic>> get relations => _relations;

  String _selectedTable = '';
  String get selectedTable => _selectedTable;
  set selectedTable(String table) {
    if (_tables.contains(table) && table != _selectedTable) {
      _selectedTable = table;
      notifyListeners();
    }
  }

  /// Queries SQLite to find Foriegn Key relations in the schema.
  populateFKRelations() async {
    // This query finds the FK relationships between distinct tables.
    // For self-joins, the condition needs to be == instead of !=.
    final query = '''
      SELECT
          m.name as fromTable
          , p.*
      FROM
          sqlite_master m
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

      await populateTablesList();
      await populateFKRelations();
    } catch (e) {
      log.severe(e);
    }
  }
}
