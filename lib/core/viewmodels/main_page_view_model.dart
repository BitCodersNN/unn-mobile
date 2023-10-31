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

  final List<String> _barScreenNames = [
    "Лента",
    "Расписание",
    "Карта",
    "Материалы",
  ];
  final List<String> _drawerScreenNames = [
    "Чаты",
    "Справки",
    "Сотрудники",
    "Календарь",
    "Подразделения",
    "Библиотечные ресурсы",
    "Сайт оплаты",
  ];
  String get selectedScreenName {
    return isDrawerItemSelected
        ? _drawerScreenNames[_selectedDrawerItem]
        : _barScreenNames[_selectedBarItem];
  }
  List<String> get drawerScreenNames => _drawerScreenNames;
  List<String> get barScreenNames => _barScreenNames;
}
