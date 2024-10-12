import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/profile_view_model.dart';

class MainPageViewModel extends BaseViewModel {
  late ProfileViewModel _profileViewModel;

  MainPageViewModel();

  ProfileViewModel get profileViewModel => _profileViewModel;

  void init() {
    setState(ViewState.busy);
    _profileViewModel = ProfileViewModel.currentUser();
  }
}
