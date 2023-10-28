import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;

  ViewState get state => _state;

  void setState(ViewState viewState) {
    _state = state;
    notifyListeners();
  }
}

enum ViewState {
  idle,
  busy,
}
