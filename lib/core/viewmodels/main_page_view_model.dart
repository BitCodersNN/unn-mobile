import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class MainPageViewModel extends BaseViewModel {
  int _selectedDrawerItem = 0;
  int _selectedBarItem = 0;
  bool _isDrawerItemSelected = false;

  int get selectedDrawerItem => _selectedDrawerItem;
  set selectedDrawerItem(int value) {
    _selectedDrawerItem = value;
    notifyListeners();
  }

  int get selectedBarItem => _selectedBarItem;
  set selectedBarItem(value) {
    _selectedBarItem = value;
    notifyListeners();
  }

  bool get isDrawerItemSelected => _isDrawerItemSelected;
  set isDrawerItemSelected(bool value) {
    _isDrawerItemSelected = value;
    notifyListeners();
  }
}
