import 'package:flutter/material.dart';

import '/core/router/generic/models/page_configuration.dart';
import '/ui/database/database_view.dart';
import '/ui/directory_select_page.dart';
import '/ui/splash_page.dart';
import '/ui/table/table_view.dart';

enum UIPages {
  splash,
  directorySelect,
  database,
  table,
}

class PageMapping {
  static const splashPath = '/splash';
  static final splashConfig = PageConfiguration(
    key: const ValueKey('splash'),
    path: splashPath,
    uiPage: UIPages.splash,
    uiWidget: const SplashPage(),
    currentPageAction: null,
  );

  static const directorySelectPath = '/';
  static final directorySelectConfig = PageConfiguration(
    key: const ValueKey('directorySelect'),
    path: '/',
    uiPage: UIPages.directorySelect,
    uiWidget: DirectorySelectView(),
    currentPageAction: null,
  );

  static const databasePath = '/database';
  static final databaseConfig = PageConfiguration(
    key: const ValueKey('database'),
    path: '/database',
    uiPage: UIPages.database,
    uiWidget: DatabaseView(),
    currentPageAction: null,
  );

  static const tablePath = '/table';
  static final tableConfig = PageConfiguration(
    key: const ValueKey('table'),
    path: '/table',
    uiPage: UIPages.table,
    uiWidget: TableView(),
    currentPageAction: null,
  );

  static PageConfiguration getConfig(UIPages page) {
    switch (page) {
      case UIPages.splash:
        return splashConfig;
      case UIPages.directorySelect:
        return directorySelectConfig;
      case UIPages.database:
        return databaseConfig;
      case UIPages.table:
        return tableConfig;
    }
  }

  static PageConfiguration getDefaultPageConfig() => splashConfig;
}
