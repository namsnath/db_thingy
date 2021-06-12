import 'package:flutter/material.dart';

import '/core/router/generic/models/page_configuration.dart';
import '/ui/directory_select_page.dart';
import '/ui/sample_page.dart';
import '/ui/splash_page.dart';

enum UIPages {
  Splash,
  DirectorySelect,
  Database,
  Table,
}

class PageMapping {
  static const SplashPath = '/splash';
  static final SplashConfig = PageConfiguration(
    key: ValueKey('Splash'),
    path: SplashPath,
    uiPage: UIPages.Splash,
    uiWidget: SplashPage(),
    currentPageAction: null,
  );

  static const DirectorySelectPath = '/';
  static final DirectorySelectConfig = PageConfiguration(
    key: ValueKey('DirectorySelect'),
    path: '/',
    uiPage: UIPages.DirectorySelect,
    uiWidget: DirectorySelectView(),
    currentPageAction: null,
  );

  static const DatabasePath = '/database';
  static final DatabaseConfig = PageConfiguration(
    key: ValueKey('Database'),
    path: '/database',
    uiPage: UIPages.Database,
    uiWidget: SamplePage(),
    currentPageAction: null,
  );

  static const TablePath = '/table';
  static final TableConfig = PageConfiguration(
    key: ValueKey('Table'),
    path: '/table',
    uiPage: UIPages.Table,
    uiWidget: SamplePage(),
    currentPageAction: null,
  );

  static PageConfiguration getConfig(UIPages page) {
    switch (page) {
      case UIPages.Splash:
        return SplashConfig;
      case UIPages.DirectorySelect:
        return DirectorySelectConfig;
      case UIPages.Database:
        return DatabaseConfig;
      case UIPages.Table:
        return TableConfig;
    }
  }

  static PageConfiguration getDefaultPageConfig() => SplashConfig;
}
