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
  // set selectedTable(String table) {
  //   if (_tables.contains(table) && table != _selectedTable) {
  //     _selectedTable = table;
  //     notifyListeners();
  //   }
  // }

  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> get tableData => _tableData;

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
      _selectedTable = '';

      // Calling notifyListeners() here since populateFKRelations() could fail and is async.
      notifyListeners();

      await populateTablesList();
      await populateFKRelations();
    } catch (e) {
      log.severe(e);
    }
  }

  selectTable(String table) async {
    if (table.isEmpty || !_tables.contains(table) || table == _selectedTable) {
      return;
    }

    if (_selectedDB != null) {
      try {
        final _colMetadata = await _selectedDB!
            .rawQuery('SELECT * FROM pragma_table_info("$table");');
        final _cols = _colMetadata
            .map((c) => '"$table"."${c['name']}" AS "${c['name']} ($table)"')
            .toList()
            .join(",");

        final _joinedTables = relations
            .where((e) => e['fromTable'] == table)
            .map((e) => e['table']);

        final _tableMetadataMapStream =
            Stream.fromIterable(_joinedTables).asyncMap(
          (t) async => MapEntry(
            t,
            await _selectedDB!
                .rawQuery('SELECT * FROM pragma_table_info("$t");'),
          ),
        );

        final _joinedColsSelectList = [];

        await for (MapEntry entry in _tableMetadataMapStream) {
          final joinedTable = entry.key;
          final metadata = entry.value;
          metadata.map((m) {
            _joinedColsSelectList.add(
                '"$joinedTable"."${m['name']}" AS "${m['name']} ($joinedTable)"');
          }).toList();
        }

        final _joinedColsSelect = _joinedColsSelectList.isNotEmpty
            ? ', ' + _joinedColsSelectList.join(', ')
            : '';

        final joins = relations
            .where((e) => e['fromTable'] == table)
            .map((e) {
              final toCol = e['to'] == 'id' ? 'rowid' : e['to'];
              return '''
                LEFT JOIN "${e['table']}" ON "$table"."${e['from']}" = "${e['table']}"."$toCol"
              '''
                  .unindent();
            })
            .toList()
            .join(" ");

        log.info(joins);

        final _data = await _selectedDB!
            .rawQuery('SELECT $_cols $_joinedColsSelect FROM "$table" $joins;');

        _selectedTable = table;
        _tableData = _data;
        notifyListeners();
      } catch (e) {
        log.severe(e);
        _selectedTable = table;
        _tableData = [];
        notifyListeners();
      }
    }
  }
}
