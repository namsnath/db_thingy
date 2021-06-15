import 'dart:io';

import 'package:db_thingy/core/services/database_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

import '/core/view_models/directory_select_view_model.dart';
import '/core/router/app_specific/app_router_state.dart';
import '/core/router/generic/models/page_action.dart';
import '/core/router/generic/enums/page_state.dart';
import '/core/router/app_specific/ui_pages.dart';

class _AppBarDirectorySelector extends StatelessWidget
    with GetItMixin, PreferredSizeWidget {
  final log = Logger('_AppBarDirectorySelector');
  final _model = GetIt.instance<DirectorySelectViewModel>();

  static const double _preferredHeight = 40.0;

  /// Opens a [FilePicker] to select directory. Updates the model with result.
  void _onFileSelectorClicked() async {
    log.fine('Calling FilePicker to fetch directory');
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    log.info('Received path: $directoryPath');

    if (directoryPath != null) {
      log.info('Creating directory from path');
      await _model.setSelectedDirectory(Directory(directoryPath));
    }
  }

  List<BreadCrumbItem> get _breadcrumbItems {
    final directory =
        watchOnly((DirectorySelectViewModel s) => s.selectedDirectory);
    final dirAllowed = watchOnly((DirectorySelectViewModel s) => s.dirAllowed);

    const enabledTextStyle = TextStyle(fontWeight: FontWeight.bold);
    const disabledTextStyle = TextStyle(color: Colors.grey);

    if (directory == null) {
      return [
        BreadCrumbItem(
          content: Text('Please select a directory'),
        ),
      ];
    }

    final pathComponents = path.split(directory.path);
    return pathComponents
        .asMap()
        .map(
          (i, e) {
            final btnPath = path.joinAll(pathComponents.sublist(0, i + 1));
            final isEnabled = i >= dirAllowed.length ? false : dirAllowed[i];

            return MapEntry(
              i,
              BreadCrumbItem(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.0,
                ),
                borderRadius: BorderRadius.circular(5.0),
                content: Text(
                  e,
                  style: isEnabled ? enabledTextStyle : disabledTextStyle,
                ),
                onTap: isEnabled
                    ? () async {
                        if (btnPath != '') {
                          log.info('Creating directory from path');
                          await _model.setSelectedDirectory(Directory(btnPath));
                        }

                        log.info(btnPath);
                      }
                    : null,
              ),
            );
          },
        )
        .values
        .toList();
  }

  BreadCrumb get _directoryBreadcrumb {
    return BreadCrumb(
      divider: Icon(Icons.chevron_right),
      overflow: ScrollableOverflow(
        direction: Axis.horizontal,
      ),
      items: _breadcrumbItems,
    );
  }

  @override
  Container build(BuildContext context) {
    return Container(
      height: _preferredHeight,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _directoryBreadcrumb,
          IconButton(
            onPressed: _onFileSelectorClicked,
            icon: Icon(Icons.folder_open_outlined),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(_preferredHeight);
}

/// A Widget that renders the directory selector.
class _DirectorySelector extends StatelessWidget with GetItMixin {
  final log = Logger('_DirectorySelector');
  final _model = GetIt.instance<DirectorySelectViewModel>();

  final double _crossAxisSpacing = 8, _mainAxisSpacing = 12, _aspectRatio = 7;
  final int _crossAxisCount = 2;

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;
    // final width = (screenWidth - ((_crossAxisCount - 1) * _crossAxisSpacing)) /
    //     _crossAxisCount;
    // final height = width / _aspectRatio;

    final directory = watchOnly(
      (DirectorySelectViewModel s) => s.selectedDirectory,
    );
    final subDirs = watchOnly(
      (DirectorySelectViewModel s) => s.subDirectories,
    );

    const boldTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
    );

    List<Widget> children = [];

    if (directory == null) {
      children = [
        const Text(
          'Please select a directory',
          style: boldTextStyle,
        ),
      ];
    } else {
      children = [
        GridView.count(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          crossAxisCount: _crossAxisCount,
          crossAxisSpacing: _crossAxisSpacing,
          mainAxisSpacing: _mainAxisSpacing,
          childAspectRatio: _aspectRatio,
          children: subDirs
              .map(
                (e) => ElevatedButton(
                  onPressed: () async {
                    await _model.setSelectedDirectory(Directory(e));
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).cardColor),
                  ),
                  child: Text(
                    path.basename(e),
                  ),
                ),
              )
              .toList(),
        ),
      ];
    }

    return Container(
      child: Column(
        children: children,
      ),
    );
  }
}

class _DatabaseButtons extends StatelessWidget with GetItMixin {
  final log = Logger('_DatabaseButtons');
  final _dbService = GetIt.I<DatabaseService>();

  final double _crossAxisSpacing = 8, _mainAxisSpacing = 12, _aspectRatio = 7;
  final int _crossAxisCount = 2;

  void _onDBSelectClick(String dbPath) async {
    try {
      var permissionGranted =
          await Permission.manageExternalStorage.request().isGranted;

      if (permissionGranted) {
        await _dbService.selectDB(dbPath);
        GetIt.I<AppRouterState>().currentAction = PageAction(
          state: PageState.addPage,
          page: PageMapping.getConfig(UIPages.Database),
        );
      }
    } catch (e) {
      log.severe(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final databases = watchOnly((DirectorySelectViewModel s) => s.dbList);

    List<Widget> children = [];

    if (databases.length > 0) {
      children = [
        Text(
          'Databases',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          crossAxisCount: _crossAxisCount,
          crossAxisSpacing: _crossAxisSpacing,
          mainAxisSpacing: _mainAxisSpacing,
          childAspectRatio: _aspectRatio,
          children: databases
              .map(
                (dbPath) => ElevatedButton(
                  child: Text(path.basename(dbPath)),
                  onPressed: () => _onDBSelectClick(dbPath),
                ),
              )
              .toList(),
        ),
      ];
    }

    return Container(
      child: Column(
        children: children,
      ),
    );
  }
}

/// A StatelessWidget to render the page to select a directory and database.
///
/// Depends on the [DirectorySelectViewModel] for state.
class DirectorySelectView extends StatelessWidget with GetItMixin {
  final log = Logger('DirectorySelectView');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DB Thingy'),
        bottom: _AppBarDirectorySelector(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DatabaseButtons(),
                Divider(thickness: 2),
                _DirectorySelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
