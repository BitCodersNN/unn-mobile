import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

class SettingsScreenViewModel extends BaseViewModel {
  final StorageService _storageService;

  SettingsScreenViewModel(this._storageService);

  int get activeNavbarRouteIndex => AppSettings.initialPage;

  set activeNavbarRouteIndex(int index) {
    AppSettings.initialPage = index;
    AppSettings.save();
    notifyListeners();
  }

  List<String> get activeNavbarRouteNames {
    return MainPageRouting.activeNavbarRoutes
        .map(
          (e) => e.pageTitle,
        )
        .toList(growable: false);
  }

  String get initialScreenName =>
      MainPageRouting.activeNavbarRoutes[AppSettings.initialPage].pageTitle;

  int get navbarRouteCount => activeNavbarRouteNames.length;

  bool get vibrationEnabled => AppSettings.vibrationEnabled;

  set vibrationEnabled(bool value) {
    AppSettings.vibrationEnabled = value;
    AppSettings.save();
    notifyListeners();
  }

  Future<void> clearCache() async {
    await Future.wait([
      DefaultCacheManager().emptyCache(),
      clearCacheFolder(),
    ]);
  }

  Future<void> clearEverything() async {
    await Future.wait([
      _storageService.clear(),
      clearCache(),
    ]);
  }

  Future<void> logout() async {
    clearEverything();
  }
}
