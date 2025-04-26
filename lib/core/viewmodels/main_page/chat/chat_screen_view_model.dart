// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/models/dialog/dialog.dart';
import 'package:unn_mobile/core/models/dialog/dialog_query_parameter.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/dialog_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class ChatScreenViewModel extends BaseViewModel {
  final DialogService _dialogService;

  static const dialogLimit = 5;
  ChatScreenViewModel(this._dialogService);

  final List<Dialog> _dialogs = [];

  Iterable<Dialog> get dialogs => _dialogs;

  bool _hasError = false;

  bool get hasError => _hasError;

  bool _hasMoreDialogs = false;

  bool get hasMoreDialogs => _hasMoreDialogs;

  void init() {
    busyCallAsync(() => _init(0));
  }

  FutureOr<void> _init(int failedAttempts) async {
    if (failedAttempts == 5) {
      _hasError = true;
      return;
    }
    _hasError = false;
    final dialogItems = await _dialogService.getDialogs(
      dialogQueryParameter: const DialogQueryParameter(
        limit: dialogLimit,
      ),
    );
    if (dialogItems == null) {
      await _init(failedAttempts + 1);
      return;
    }
    _hasMoreDialogs = dialogItems.hasMore;
    _dialogs.addAll(dialogItems.items);
  }

  FutureOr<void> loadMore() async {
    final dialogItems = await _dialogService.getDialogs(
      dialogQueryParameter: DialogQueryParameter(
        limit: dialogLimit,
        lastMessageDate: _dialogs.last.previewMessage.dateTime,
      ),
    );
    if (dialogItems == null) {
      return;
    }
    _dialogs.addAll(dialogItems.items);
    _hasMoreDialogs = dialogItems.hasMore;
  }
}
