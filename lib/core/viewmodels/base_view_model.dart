import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;

  ViewState get state => _state;
  bool _disposed = false;

  void setState(ViewState viewState) {
    if(_disposed)
    {
      return;
    }
    _state = viewState;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

enum ViewState {
  idle,
  busy,
}
