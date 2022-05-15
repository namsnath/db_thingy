import 'package:flutter/material.dart';

import '/core/router/generic/models/page_configuration.dart';
import 'ui_pages.dart';

class CustomRouteParser extends RouteInformationParser<PageConfiguration> {
  @override
  Future<PageConfiguration> parseRouteInformation(
      RouteInformation routeInformation) async {
    // Parse the location String to a Uri
    final uri = Uri.parse(routeInformation.location ?? '/');
    // If no paths present, show Splash page
    if (uri.pathSegments.isEmpty) {
      return PageMapping.splashConfig;
    }

    // If paths present, get first path from Uri
    final path = uri.pathSegments[0];
    // Return PageConfiguration according to first path segment
    switch (path) {
      case PageMapping.splashPath:
        return PageMapping.splashConfig;
      case PageMapping.directorySelectPath:
        return PageMapping.directorySelectConfig;
      case PageMapping.databasePath:
        return PageMapping.databaseConfig;
      case PageMapping.tablePath:
        return PageMapping.tableConfig;
      default:
        return PageMapping.splashConfig;
    }
  }

  @override
  RouteInformation restoreRouteInformation(PageConfiguration configuration) {
    switch (configuration.uiPage) {
      case UIPages.splash:
        return const RouteInformation(location: PageMapping.splashPath);
      case UIPages.directorySelect:
        return const RouteInformation(
            location: PageMapping.directorySelectPath);
      case UIPages.database:
        return const RouteInformation(location: PageMapping.databasePath);
      case UIPages.table:
        return const RouteInformation(location: PageMapping.tablePath);
      default:
        return const RouteInformation(location: PageMapping.splashPath);
    }
  }
}
