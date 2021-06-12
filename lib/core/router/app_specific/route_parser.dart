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
      return PageMapping.SplashConfig;
    }

    // If paths present, get first path from Uri
    final path = uri.pathSegments[0];
    // Return PageConfiguration according to first path segment
    switch (path) {
      case PageMapping.SplashPath:
        return PageMapping.SplashConfig;
      case PageMapping.DirectorySelectPath:
        return PageMapping.DirectorySelectConfig;
      case PageMapping.TablePath:
        return PageMapping.TableConfig;
      default:
        return PageMapping.SplashConfig;
    }
  }

  @override
  RouteInformation restoreRouteInformation(PageConfiguration configuration) {
    switch (configuration.uiPage) {
      case UIPages.Splash:
        return const RouteInformation(location: PageMapping.SplashPath);
      case UIPages.DirectorySelect:
        return const RouteInformation(
            location: PageMapping.DirectorySelectPath);
      case UIPages.Table:
        return const RouteInformation(location: PageMapping.TablePath);
      default:
        return const RouteInformation(location: PageMapping.SplashPath);
    }
  }
}
