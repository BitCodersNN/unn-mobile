import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class MainPageViewModel extends BaseViewModel {
  final GettingProfileOfCurrentUser _currentUser = Injector.appInstance.get<GettingProfileOfCurrentUser>();
  int _selectedDrawerItem = 0;
  int _selectedBarItem = 1;
  bool _isDrawerItemSelected = false;
  String _userNameAndSurname = '';
  String _userGroup = '';
  
  ImageProvider<Object>? _userAvatar;
  String? get avatarUrl => _avatarUrl;
  String? _avatarUrl;

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
    "О нас",
    "Выйти"
  ];
  String get selectedScreenName {
    return isDrawerItemSelected
        ? _drawerScreenNames[_selectedDrawerItem]
        : _barScreenNames[_selectedBarItem];
  }
  List<String> get drawerScreenNames => _drawerScreenNames;
  List<String> get barScreenNames => _barScreenNames;
  
  ImageProvider<Object>? get userAvatar => _userAvatar;
  String get userNameAndSurname => _userNameAndSurname;
  String get userGroup => _userGroup;

  void init()
  {
    setState(ViewState.busy);
    _currentUser.getProfileOfCurrentUser().then(
      (value) {
        if(value == null)
        {
          setState(ViewState.idle);
          return;
        }
        if(value is StudentData)
        {
          final StudentData studentProfile = value;
          _userNameAndSurname = '${studentProfile.name} ${studentProfile.lastname}';
          _userGroup = studentProfile.eduGroup;
          _userAvatar = studentProfile.fullUrlPhoto == null ? null : CachedNetworkImageProvider(studentProfile.fullUrlPhoto!);
        }
        setState(ViewState.idle);
      }
    );
  }
}
