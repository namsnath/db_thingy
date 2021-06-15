import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '/core/services/database_service.dart';

class _TableButtons extends StatelessWidget with GetItMixin {
  final log = Logger('_TableButtons');
  final _dbService = GetIt.I<DatabaseService>();

  final double _crossAxisSpacing = 8, _mainAxisSpacing = 12, _aspectRatio = 7;
  final int _crossAxisCount = 2;

  @override
  Widget build(BuildContext context) {
    final tables = watchOnly((DatabaseService s) => s.tables);

    return Container(
      child: GridView.count(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        crossAxisCount: _crossAxisCount,
        crossAxisSpacing: _crossAxisSpacing,
        mainAxisSpacing: _mainAxisSpacing,
        childAspectRatio: _aspectRatio,
        children: tables
            .map(
              (table) => ElevatedButton(
                child: Text(table),
                onPressed: () async {
                  _dbService.selectedTable = table;
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class DatabaseView extends StatelessWidget with GetItMixin {
  final log = Logger('DatabaseView');

  List<Widget> get relationsList {
    final relations = watchOnly((DatabaseService s) => s.relations);

    return relations
        .map(
          (e) => Text(
              '${e['fromTable']} (${e['from']}) ➜ ${e['table']} (${e['to']})'),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDBPath = watchOnly((DatabaseService s) => s.selectedDBPath);
    final selectedTable = watchOnly((DatabaseService s) => s.selectedTable);

    return Scaffold(
      appBar: AppBar(
        title: Text(path.basename(selectedDBPath)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TableButtons(),
              Divider(),
              ...relationsList,
              Text(selectedTable),
            ],
          ),
        ),
      ),
    );
  }
}