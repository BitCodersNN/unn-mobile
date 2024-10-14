part of 'package:unn_mobile/core/viewmodels/library.dart';

class MainPageViewModel extends BaseViewModel {
  late ProfileViewModel _profileViewModel;

  MainPageViewModel();

  ProfileViewModel get profileViewModel => _profileViewModel;

  void init() {
    setState(ViewState.busy);
    _profileViewModel = ProfileViewModel.currentUser();
  }
}
