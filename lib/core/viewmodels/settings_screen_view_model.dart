part of 'package:unn_mobile/core/viewmodels/library.dart';

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
