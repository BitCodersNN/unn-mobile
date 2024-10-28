import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;

  bool disposed = false;

  @protected
  bool isInitialized = false;

  bool get initialized => isInitialized;

  bool get isBusy => _state == ViewState.busy;

  ViewState get state => _state;

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

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }
}

enum ViewState {
  idle,
  busy,
}
