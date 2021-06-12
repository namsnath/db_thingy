import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '/core/router/generic/models/page_action.dart';
import '/core/router/generic/enums/page_state.dart';
import 'ui_pages.dart';

/// A [ChangeNotifier] that tracks the global state of the App. Mainly deals with routing.
///
/// This is used by [CustomRouterDelegate] in it's initialization and is listened to
/// in order to track changes to the state and update the [Navigator] accordingly.
class AppRouterState extends ChangeNotifier {
  final log = Logger('AppRouterState');

  bool _splashFinished = false;
  bool get splashFinished => _splashFinished;

  PageAction _currentAction = PageAction();
  PageAction get currentAction => _currentAction;
  set currentAction(PageAction action) {
    _currentAction = action;
    notifyListeners();
  }

  void resetCurrentAction() {
    _currentAction = PageAction();
  }

  void setSplashFinished() {
    log.fine('Splash finished');
    _splashFinished = true;
    _currentAction = PageAction(
      state: PageState.replaceAll,
      page: PageMapping.getConfig(UIPages.DirectorySelect),
    );
    notifyListeners();
  }
}
