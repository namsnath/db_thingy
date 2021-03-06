import 'package:get_it/get_it.dart';

import '/core/view_models/directory_select_view_model.dart';
import '/core/router/app_specific/app_router_state.dart';
import 'database_service.dart';
import 'settings_service.dart';
import 'shared_prefs_service.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerSingletonAsync(() async => SharedPrefsService().init());
  getIt.registerSingleton(AppRouterState());
  getIt.registerSingleton(DatabaseService());

  getIt.registerSingletonWithDependencies<SettingsService>(
    () => SettingsService(),
    dependsOn: [SharedPrefsService],
  );

  getIt.registerSingletonAsync<DirectorySelectViewModel>(
    () => DirectorySelectViewModel().init(),
    dependsOn: [SharedPrefsService],
  );
}
