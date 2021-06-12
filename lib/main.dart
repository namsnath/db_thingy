import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

import 'core/router/app_specific/app_router_state.dart';
import 'core/router/generic/back_button_dispatcher.dart';
import 'core/services/locator.dart';
import 'core/router/generic/router_delegate.dart';
import 'core/router/app_specific/route_parser.dart';

void main() {
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(
    (record) {
      print(
          '${record.level.name} (${record.loggerName}): ${record.time}: ${record.message}');
    },
  );

  // Avoid cast errors in SharedPreferences if called in MyApp
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();
  runApp(DBThingyApp());
}

/// The top-level app widget that builds the DBThingy app.
class DBThingyApp extends StatelessWidget {
  final GlobalKey routerAppKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final appState = GetIt.instance<AppRouterState>();
    final delegate = CustomRouterDelegate(appState);
    final backButtonDispatcher = CustomBackButtonDispatcher(delegate);

    return MaterialApp.router(
      key: routerAppKey,
      title: 'DB Thingy',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerDelegate: delegate,
      routeInformationParser: CustomRouteParser(),
      backButtonDispatcher: backButtonDispatcher,
    );
  }
}
