import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;

  ViewState get state => _state;
  bool get isBusy => _state == ViewState.busy;

  bool disposed = false;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!disposed) {
      WidgetsBinding.instance.endOfFrame.whenComplete(
        () => super.notifyListeners(),
      );
    }
  }
}

enum ViewState {
  idle,
  busy,
}
