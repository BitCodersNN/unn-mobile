// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

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

  FutureOr<void> busyCallAsync(FutureOr<void> Function() task) async {
    if (isBusy) {
      return;
    }
    try {
      setState(ViewState.busy);
      await task();
    } finally {
      setState(ViewState.idle);
    }
  }

  FutureOr<T?> typedBusyCallAsync<T>(FutureOr<T> Function() task) async {
    if (isBusy) {
      return null;
    }
    try {
      setState(ViewState.busy);
      return await task();
    } finally {
      setState(ViewState.idle);
    }
  }

  FutureOr<void> changeState(FutureOr<void> Function() task) async {
    try {
      await task();
    } finally {
      notifyListeners();
    }
  }
}

enum ViewState {
  idle,
  busy,
}
