import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_route_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

class MainPageViewModel extends BaseViewModel {
  final CurrentUserSyncStorage _currentUserSyncStorage;
  late ProfileViewModel _profileViewModel;

  List<MainPageRouteData> _routes = [];

  MainPageViewModel(this._currentUserSyncStorage);

  ProfileViewModel get profileViewModel => _profileViewModel;
  List<MainPageRouteData> get routes => _routes;

  void init() {
    if (isInitialized) {
      return;
    }
    _routes = MainPageRouting.drawerRoutes
        .where(
          (route) =>
              route.userTypes.isEmpty ||
              route.userTypes.contains(_currentUserSyncStorage.typeOfUser),
        )
        .toList(growable: false);
    isInitialized = true;
    _profileViewModel = ProfileViewModel.currentUser();
  }

  void refreshTab(int index) {
    final tab = Injector.appInstance
        .get<MainPageRoutesViewModelsFactory>()
        .getViewModelByRouteIndex(index);
    if (tab is MainPageRouteViewModel) {
      (tab as MainPageRouteViewModel).refresh();
    }
  }
}
