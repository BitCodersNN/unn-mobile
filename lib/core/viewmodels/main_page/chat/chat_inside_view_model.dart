// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:unn_mobile/core/aggregators/interfaces/message_service_aggregator.dart';
import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/dialog/base_dialog_info.dart';
import 'package:unn_mobile/core/models/dialog/dialog.dart';
import 'package:unn_mobile/core/models/dialog/message/enum/message_state.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_screen_view_model.dart';

class ChatInsideViewModel extends BaseViewModel {
  final MainPageRoutesViewModelsFactory _routesViewModelFactory;
  final MessageServiceAggregator _messagesAggregator;
  final CurrentUserSyncStorage _currentUserSyncStorage;

  ChatScreenViewModel? _dialogsViewModel;

  BaseDialogInfo? _dialog;

  int? chatId;

  bool _hasError = false;

  int? _lastReadMessageId;

  int? get lastReadMessageId => _lastReadMessageId;

  final List<List<List<Message>>> _messages = [];

  final List<Message> _unpartitionedMessages = [];

  bool _hasMessagesBefore = false;

  bool _hasMessagesAfter = false;

  bool refreshLoopStopFlag = false;

  bool _isInitializing = false;

  bool refreshLoopRunning = false;
  Message? _replyMessage;

  ChatInsideViewModel(
    this._routesViewModelFactory,
    this._messagesAggregator,
    this._currentUserSyncStorage,
  );
  int? get currentUserId => _currentUserSyncStorage.currentUserData?.bitrixId;

  int get unreadMessagesCount =>
      (_dialog is Dialog) ? (_dialog! as Dialog).unreadMessagesCount : 0;

  BaseDialogInfo? get dialog => _dialog;
  bool get hasError => _hasError;

  bool get hasMessagesAfter => _hasMessagesAfter;

  bool get hasMessagesBefore => _hasMessagesBefore;

  Iterable<Iterable<Iterable<Message>>> get messages => _messages;

  Message? get replyMessage => _replyMessage;

  set replyMessage(Message? replyMessage) {
    _replyMessage = replyMessage;
    notifyListeners();
  }

  Future<PaginatedResult<Message>?> getMessagesByDialogId(
    String dialogId,
  ) async {
    final messages =
        await _messagesAggregator.fetchByDialogId(dialogId: dialogId);
    if (messages == null) {
      return null;
    }
    if (messages is PaginatedResultWithChatId<Message>) {
      chatId = messages.chatId;
    }
    return messages;
  }

  FutureOr<void> getNewMessages() async {
    if (_dialog == null) {
      return;
    }

    final messages = await tryLoginAndRetrieveData<PaginatedResult<Message>>(
      () => chatId == null
          ? getMessagesByDialogId(_dialog!.dialogId.stringValue)
          : _messagesAggregator.fetchByChatId(chatId: chatId!),
      () => null,
    );
    if (messages == null) {
      _hasError = true;
      return;
    }
    if (chatId != null) {
      await _readMessages(chatId!, messages.items);
    }
    final messagesToRemove = messages.items.length -
        messages.items.reversed
            .takeWhile(
              (m) =>
                  m.messageId != _unpartitionedMessages.firstOrNull?.messageId,
            )
            .length;

    if (refreshLoopRunning && !refreshLoopStopFlag) {
      await _dialogsViewModel!.init();

      fetchDialogFromRoot(chatId);

      _dialogsViewModel!.notifyListeners();
    }
    _unpartitionedMessages
      ..removeRange(
        0,
        min(messagesToRemove, _unpartitionedMessages.length),
      )
      ..insertAll(0, messages.items.reversed);

    _messages
      ..clear()
      ..addAll(_partitionMessages(_unpartitionedMessages));
  }

  void fetchDialogFromRoot(int? chatId) {
    final viewModel = _dialogsViewModel;
    final storedInfo = viewModel?.storedDialogInfo;

    if (viewModel == null && storedInfo == null) {
      _dialog = null;
      return;
    }

    _dialog = viewModel?.dialogs.cast<BaseDialogInfo>().firstWhere(
              (d) => d is Dialog && d.chatId == chatId,
              orElse: () => storedInfo!,
            ) ??
        storedInfo;
  }

  FutureOr<void> init(int? chatId) async {
    _isInitializing = true;
    try {
      await busyCallAsync(() => _init(chatId));
    } finally {
      _isInitializing = false;
    }
  }

  FutureOr<void> loadMoreMessages() async => await busyCallAsync(() async {
        if (_dialog == null) {
          return;
        }
        if (_isInitializing) {
          return;
        }
        if (!_hasMessagesBefore) {
          return;
        }
        final messages =
            await tryLoginAndRetrieveData<PaginatedResult<Message>?>(
          () => chatId == null
              ? getMessagesByDialogId(_dialog!.dialogId.stringValue)
              : _messagesAggregator.fetchByChatId(
                  chatId: chatId!,
                  lastMessageId: _unpartitionedMessages.last.messageId,
                ),
          () => null,
        );
        if (messages == null) {
          _hasError = true;
          return;
        }
        if (chatId != null) {
          await _readMessages(chatId!, messages.items);
        }
        _unpartitionedMessages.addAll(messages.items);
        _messages
          ..clear()
          ..addAll(_partitionMessages(_unpartitionedMessages));
        _hasMessagesBefore = messages.hasNextPage;
      });

  Future<void> refreshLoop({bool checkStartConditions = true}) async {
    if (checkStartConditions) {
      if (refreshLoopRunning) {
        return;
      }
      refreshLoopRunning = true;
    }

    if (refreshLoopStopFlag) {
      return;
    }
    await Future.delayed(const Duration(seconds: 5));
    if (!_isInitializing) {
      await getNewMessages();
      notifyListeners();
    }
    await refreshLoop(checkStartConditions: false);
  }

  FutureOr<bool> sendFiles(Iterable<String> uris, {String? text}) =>
      _sendMessageWrapper<List<FileData>>(
        () => _messagesAggregator.sendFiles(
          chatId: chatId!,
          files: [for (final uri in uris) File(uri)],
          text: text,
        ),
      );

  FutureOr<bool> sendMessage(String text) async =>
      await _sendMessageWrapper<int>(
        () async => _replyMessage == null
            ? await _messagesAggregator.send(
                dialogId: _dialog?.dialogId.stringValue ?? '',
                text: text,
              )
            : await _messagesAggregator.reply(
                dialogId: _dialog?.dialogId.stringValue ?? '',
                text: text,
                replyMessageId: _replyMessage!.messageId,
              ),
      );

  FutureOr<void> _init(int? chatId) async {
    _hasError = false;
    _hasMessagesBefore = false;
    _hasMessagesAfter = false;
    this.chatId = chatId;
    _messages.clear();
    _unpartitionedMessages.clear();
    _dialogsViewModel =
        _routesViewModelFactory.getViewModelByType<ChatScreenViewModel>();
    fetchDialogFromRoot(chatId);
    final messages = await tryLoginAndRetrieveData<PaginatedResult<Message>>(
      () => this.chatId == null
          ? getMessagesByDialogId(_dialog!.dialogId.stringValue)
          : _messagesAggregator.fetchByChatId(chatId: this.chatId!),
      () => null,
    );
    if (messages == null) {
      _hasError = true;
      return;
    }
    if (this.chatId != null) {
      await _readMessages(this.chatId!, messages.items);
    }
    _unpartitionedMessages.addAll(messages.items.reversed);
    _messages.addAll(_partitionMessages(messages.items.reversed));
    _hasMessagesBefore = messages.hasPreviousPage;
    _hasMessagesAfter = messages.hasNextPage;

    unawaited(refreshLoop());
  }

  List<List<List<Message>>> _partitionMessages(Iterable<Message> messages) {
    const maxTimeDifference = 5;
    final List<List<List<Message>>> partitions = [];
    for (final (index, message) in messages.indexed) {
      final lastDatePartition = partitions.lastOrNull;
      final lastPartititon = lastDatePartition?.lastOrNull;
      final lastMessage = lastPartititon?.lastOrNull;

      final lastMessageAuthorId = lastMessage?.author?.bitrixId ?? -2;
      final messageAuthorId = message.author?.bitrixId;
      final timeDifference = lastMessage?.dateTime //
              .difference(message.dateTime)
              .inMinutes
              .abs() ??
          maxTimeDifference;
      if (index == unreadMessagesCount) {
        _lastReadMessageId = index == 0 ? null : message.messageId;
      }
      if (!(lastMessage?.dateTime.isSameDate(message.dateTime) ?? false)) {
        partitions.add(
          [
            [message],
          ],
        );
        continue;
      }
      if (lastMessageAuthorId == messageAuthorId &&
          timeDifference < maxTimeDifference &&
          message.messageStatus != MessageState.system &&
          index != unreadMessagesCount) {
        lastPartititon?.add(message);
        continue;
      }

      lastDatePartition?.add([message]);
    }
    _lastReadMessageId ??= -1;
    return partitions;
  }

  Future<void> _readMessages(
    int chatId,
    List<Message> messages,
  ) async {
    await _messagesAggregator.readMessages(
      chatId: chatId,
      messageIds: messages.map((m) => m.messageId),
    );
  }

  FutureOr<bool> _sendMessageWrapper<T>(
    FutureOr<T?> Function() sendFunction,
  ) async =>
      await typedBusyCallAsync<bool>(() async {
        if (_dialog == null) {
          return false;
        }
        if (chatId == null) {
          return false;
        }
        final result = await tryLoginAndRetrieveData<T>(
          sendFunction,
          () => null,
        );

        await getNewMessages();
        replyMessage = null;

        return result != null;
      }) ??
      false;
}
