// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/dialog/dialog.dart';
import 'package:unn_mobile/core/models/dialog/dialog_query_parameter.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/dialog_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class ChatScreenViewModel extends BaseViewModel {
  static const dialogLimit = 30;
  static const maxRetryAttempts = 5;

  final DialogService _dialogService;

  final CurrentUserSyncStorage _currentUserSyncStorage;

  final List<Dialog> _dialogs = [];

  int? _currentUserId;

  bool _hasError = false;

  bool _hasMoreDialogs = false;

  ChatScreenViewModel(this._dialogService, this._currentUserSyncStorage);

  int? get currentUserId => _currentUserId;

  Iterable<Dialog> get dialogs => _dialogs;

  bool get hasError => _hasError;

  bool get hasMoreDialogs => _hasMoreDialogs;

  FutureOr<void> init() async {
    await busyCallAsync(() => _init(0));
  }

  FutureOr<void> loadMore() async => busyCallAsync(() async {
        _hasError = false;
        final dialogItems = await _getDialogItems(
          limit: dialogLimit,
          lastMessageDate: _dialogs.last.previewMessage.dateTime,
        );
        if (dialogItems == null) {
          return;
        }
        _dialogs.addAll(dialogItems.items);
        _hasMoreDialogs = dialogItems.hasMore;
      });

  Future<PartialResult<Dialog>?> _getDialogItems({
    required int limit,
    DateTime? lastMessageDate,
  }) async {
    return await tryLoginAndRetrieveData<PartialResult<Dialog>>(
      () async => await _dialogService.getDialogs(
        dialogQueryParameter: DialogQueryParameter(
          limit: limit,
          lastMessageDate: lastMessageDate,
        ),
      ),
      () => null,
    );
  }

  FutureOr<void> _init(int failedAttempts) async {
    if (failedAttempts == maxRetryAttempts) {
      _hasError = true;
      return;
    }
    _hasError = false;
    _dialogs.clear();
    final dialogItems = await _getDialogItems(limit: dialogLimit);
    if (dialogItems == null) {
      await _init(failedAttempts + 1);
      return;
    }
    _hasMoreDialogs = dialogItems.hasMore;
    _dialogs.addAll(dialogItems.items);

    _currentUserId = _currentUserSyncStorage.currentUserData?.bitrixId;
  }
}
