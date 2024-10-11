import 'package:injector/injector.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page_route_view_model.dart';
import 'package:unn_mobile/core/viewmodels/profile_view_model.dart';

class MainPageViewModel extends BaseViewModel {
  late ProfileViewModel _profileViewModel;

  MainPageViewModel();

  ProfileViewModel get profileViewModel => _profileViewModel;

  void init() {
    if (isInitialized) {
      return;
    }
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
