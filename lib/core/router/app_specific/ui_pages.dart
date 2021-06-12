import 'package:db_thingy/ui/directory_select_page.dart';
import 'package:db_thingy/ui/sample_page.dart';
import 'package:db_thingy/ui/splash_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/core/router/generic/models/page_configuration.dart';

enum UIPages {
  Splash,
  DirectorySelect,
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
    uiWidget: DirectorySelectPage(),
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
      case UIPages.Table:
        return TableConfig;
    }
  }

  static PageConfiguration getDefaultPageConfig() => SplashConfig;
}
