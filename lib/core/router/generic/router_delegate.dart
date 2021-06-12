import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '/core/router/app_specific/app_state.dart';
import '/core/router/app_specific/ui_pages.dart';
import '/core/router/generic/models/page_action.dart';
import '/core/router/generic/models/page_configuration.dart';
import '/core/router/generic/enums/page_state.dart';

class CustomRouterDelegate extends RouterDelegate<PageConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageConfiguration> {
  final log = Logger('CustomRouterDelegate');

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final AppState appState;
  final List<Page> _pages = [];

  /// A [RouterDelegate] that handles the actual routing and page stack.
  ///
  /// Listens to an AppState instance. This class is for internal navigation and
  /// should not need to be referenced outside of initialising the Navigator.
  CustomRouterDelegate(this.appState) : navigatorKey = GlobalKey() {
    appState.addListener(() {
      notifyListeners();
    });

    setNewRoutePath(PageMapping.getDefaultPageConfig());
  }

  List<MaterialPage> get pages => List.unmodifiable(_pages);
  int numPages() => _pages.length;

  @override
  PageConfiguration get currentConfiguration =>
      _pages.last.arguments as PageConfiguration;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: buildPages(),
    );
  }

  bool canPop() {
    return _pages.length > 1;
  }

  /// Removes a page from the stack.
  void _removePage(Page page) {
    _pages.remove(page);

    /// Without [notifyListeners()] Android back button press is ignored.
    notifyListeners();
  }

  void pop() {
    if (canPop()) {
      _removePage(_pages.last);
    }
  }

  bool _onPopPage(Route<dynamic> route, result) {
    final didPop = route.didPop(result);
    if (!didPop) {
      return false;
    }

    if (canPop()) {
      pop();
      return true;
    }

    return false;
  }

  @override
  Future<bool> popRoute() {
    if (canPop()) {
      _removePage(_pages.last);
      return Future.value(true);
    }
    return Future.value(false);
  }

  MaterialPage _createPage(Widget child, PageConfiguration pageConfig) {
    return MaterialPage(
      child: child,
      key: ValueKey(pageConfig.key),
      name: pageConfig.path,
      arguments: pageConfig,
    );
  }

  void _addPageData(Widget child, PageConfiguration pageConfig) {
    _pages.add(
      _createPage(child, pageConfig),
    );
  }

  void addPage(PageConfiguration pageConfig) {
    final shouldAddPage =
        _pages.isEmpty || currentConfiguration.uiPage != pageConfig.uiPage;

    if (shouldAddPage) {
      final config = PageMapping.getConfig(pageConfig.uiPage);
      _addPageData(config.uiWidget, config);

      /// Ideally, this should be moved to [PageMapping] or a similar class so as
      /// to keep app-specific logic in the router to a minimum.
      /// For custom behaviour in some cases, use this:
      // if (pageConfig.currentPageAction != null) {
      //   _addPageData(pageConfig.currentPageAction.widget, pageConfig);
      // }
    }
  }

  /// Remove the last page and replace with the new page using `addPage()`.
  void replace(PageConfiguration newRoute) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    addPage(newRoute);
  }

  /// Clears the whole stack and adds all the pages provided.
  void setPath(List<MaterialPage> path) {
    _pages.clear();
    _pages.addAll(path);
  }

  /// Calls `setNewRoutePath()`.
  void replaceAll(PageConfiguration newRoute) {
    setNewRoutePath(newRoute);
  }

  /// Same as `addPage()`.
  void push(PageConfiguration newRoute) {
    addPage(newRoute);
  }

  /// Allows adding a new `Widget` to the stack.
  void pushWidget(Widget child, PageConfiguration newRoute) {
    _addPageData(child, newRoute);
  }

  /// Adds a list of pages from their `routes`.
  void addAll(List<PageConfiguration> routes) {
    _pages.clear();
    routes.forEach((route) {
      addPage(route);
    });
  }

  /// Clears the list of pages and adds a new page.
  @override
  Future<void> setNewRoutePath(PageConfiguration configuration) {
    final shouldAddPage =
        _pages.isEmpty || currentConfiguration.uiPage != configuration.uiPage;

    if (shouldAddPage) {
      _pages.clear();
      addPage(configuration);
    }

    return Future.value(null);
  }

  void _setPageAction(PageAction action) {
    final page = action.page?.uiPage;
    if (page != null) {
      final config = PageMapping.getConfig(page);
      config.currentPageAction = action;
    }
  }

  List<Page> buildPages() {
    if (!appState.splashFinished) {
      replaceAll(PageMapping.getDefaultPageConfig());
    } else {
      switch (appState.currentAction.state) {
        case PageState.none:
          break;

        case PageState.addPage:
          _setPageAction(appState.currentAction);
          final page = appState.currentAction.page;
          if (page != null) {
            addPage(page);
          }
          break;

        case PageState.pop:
          pop();
          break;

        case PageState.replace:
          _setPageAction(appState.currentAction);
          final page = appState.currentAction.page;
          if (page != null) {
            replace(page);
          }
          break;

        case PageState.replaceAll:
          _setPageAction(appState.currentAction);
          final page = appState.currentAction.page;
          if (page != null) {
            replaceAll(page);
          }
          break;

        case PageState.addWidget:
          _setPageAction(appState.currentAction);
          final widget = appState.currentAction.widget;
          final page = appState.currentAction.page;

          if (widget != null && page != null) {
            pushWidget(widget, page);
          }
          break;

        case PageState.addAll:
          final pages = appState.currentAction.pages;
          if (pages != null) {
            addAll(pages);
          }
          break;
      }
    }
    appState.resetCurrentAction();
    return List.of(_pages);
  }
}
