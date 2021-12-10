import 'package:db_thingy/core/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

class _TableData extends StatelessWidget with GetItMixin {
  final log = Logger('_TableData');
  final _dbService = GetIt.I<DatabaseService>();

  @override
  Widget build(BuildContext context) {
    final tableData = watchOnly((DatabaseService s) => s.tableData);
    List<DataRow> rows = [];
    List<DataColumn> columns = [];

    if (tableData.length > 0) {
      columns = tableData[0]
          .keys
          .map(
            (col) => DataColumn(
              label: Text(col, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
          .toList();

      final dataRows = tableData
          .map(
            (e) => DataRow(
              cells: e
                  .map(
                    (key, value) =>
                        MapEntry(key, DataCell(Text(value?.toString() ?? ''))),
                  )
                  .values
                  .toList(),
            ),
          )
          .toList();
      rows = dataRows;
    } else {
      columns = [DataColumn(label: Text('No Data'))];
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }
}

class TableView extends StatelessWidget with GetItMixin {
  @override
  Widget build(BuildContext context) {
    final selectedDBPath = watchOnly((DatabaseService s) => s.selectedDBPath);
    final selectedTable = watchOnly((DatabaseService s) => s.selectedTable);

    return Scaffold(
      appBar: AppBar(
        title: Text('$selectedTable (${path.basename(selectedDBPath)})'),
      ),
      body: Padding(
        padding: EdgeInsets.all(25),
        child: Center(
          child: Column(
            children: [
              _TableData(),
            ],
          ),
        ),
      ),
    );
  }
}
