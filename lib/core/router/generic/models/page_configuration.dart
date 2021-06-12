import 'package:flutter/material.dart';

import 'page_action.dart';
import '/core/router/app_specific/ui_pages.dart';

class PageConfiguration {
  final ValueKey key;
  final String path;
  final UIPages uiPage;
  final Widget uiWidget;
  PageAction? currentPageAction;

  /// Configurations to be used in the [CustomRouterDelegate].
  PageConfiguration({
    required this.key,
    required this.path,
    required this.uiPage,
    required this.uiWidget,
    this.currentPageAction,
  });
}
