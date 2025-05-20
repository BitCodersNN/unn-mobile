// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:unn_mobile/core/aggregators/intefaces/message_service_aggregator.dart';
import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/dialog/dialog.dart';
import 'package:unn_mobile/core/models/dialog/group_dialog.dart';
import 'package:unn_mobile/core/models/dialog/message/enum/message_state.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/models/dialog/user_dialog.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_screen_view_model.dart';

class ChatInsideViewModel extends BaseViewModel {
  final MainPageRoutesViewModelsFactory _routesViewModelFactory;
  final MessageServiceAggregator _messagesAggregator;
  final CurrentUserSyncStorage _currentUserSyncStorage;

  Dialog? _dialog;

  bool _hasError = false;

  final List<List<List<Message>>> _messages = [];

  final List<Message> _unpartitionedMessages = [];

  bool _hasMessagesBefore = false;

  bool _hasMessagesAfter = false;

  bool refreshLoopStopFlag = false;

  bool refreshLoopRunning = false;
  Message? _replyMessage;

  ChatInsideViewModel(
    this._routesViewModelFactory,
    this._messagesAggregator,
    this._currentUserSyncStorage,
  );
  int? get currentUserId => _currentUserSyncStorage.currentUserData?.bitrixId;

  Dialog? get dialog => _dialog;
  bool get hasError => _hasError;

  bool get hasMessagesAfter => _hasMessagesAfter;

  bool get hasMessagesBefore => _hasMessagesBefore;

  Iterable<Iterable<Iterable<Message>>> get messages => _messages;

  Message? get replyMessage => _replyMessage;

  set replyMessage(Message? replyMessage) {
    _replyMessage = replyMessage;
    notifyListeners();
  }

  FutureOr<void> getNewMessages() async {
    if (_dialog == null) {
      return;
    }

    final messages = await tryLoginAndRetrieveData<PaginatedResult<Message>>(
      () async => await _messagesAggregator.fetch(chatId: _dialog!.chatId),
      () => null,
    );
    if (messages == null) {
      _hasError = true;
      return;
    }
    await _readMessages(_dialog!.chatId, messages);

    final messagesToRemove = messages.items.length -
        messages.items.reversed
            .takeWhile(
              (m) =>
                  m.messageId != _unpartitionedMessages.firstOrNull?.messageId,
            )
            .length;

    _unpartitionedMessages.removeRange(
      0,
      max(messagesToRemove, _unpartitionedMessages.length),
    );
    _unpartitionedMessages.insertAll(0, messages.items.reversed);

    _messages
      ..clear()
      ..addAll(_partitionMessages(_unpartitionedMessages));
  }

  FutureOr<void> init(int chatId) async {
    await busyCallAsync(() => _init(chatId));
  }

  FutureOr<void> loadMoreMessages() async => await busyCallAsync(() async {
        if (_dialog == null) {
          return;
        }
        if (!_hasMessagesBefore) {
          return;
        }
        final messages =
            await tryLoginAndRetrieveData<PaginatedResult<Message>?>(
          () async => await _messagesAggregator.fetch(
            chatId: _dialog!.chatId,
            lastMessageId: _unpartitionedMessages.last.messageId,
          ),
          () => null,
        );
        if (messages == null) {
          _hasError = true;
          return;
        }
        await _readMessages(_dialog!.chatId, messages);
        _unpartitionedMessages.addAll(messages.items);
        _messages
          ..clear()
          ..addAll(_partitionMessages(_unpartitionedMessages));
        _hasMessagesBefore = messages.hasPreviousPage;
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

    await getNewMessages();

    notifyListeners();

    await refreshLoop(checkStartConditions: false);
  }

  FutureOr<bool> sendFiles(Iterable<String> uris, {String? text}) async =>
      _sendMessageWrapper<List<FileData>>(() async {
        return await _messagesAggregator.sendFiles(
          chatId: _dialog!.chatId,
          files: uris.map((e) => File(e)).toList(),
          text: text,
        );
      });

  FutureOr<bool> sendMessage(String text) async =>
      await _sendMessageWrapper<int>(() async {
        final dialogId = switch (_dialog) {
          final UserDialog userDialog => userDialog.id.toString(),
          final GroupDialog groupDialog => groupDialog.id,
          _ => '',
        };
        return _replyMessage == null
            ? await _messagesAggregator.send(
                dialogId: dialogId,
                text: text,
              )
            : await _messagesAggregator.reply(
                dialogId: dialogId,
                text: text,
                replyMessageId: _replyMessage!.messageId,
              );
      });

  FutureOr<void> _init(int chatId) async {
    _hasError = false;
    _hasMessagesBefore = false;
    _hasMessagesAfter = false;
    _messages.clear();
    _dialog = _routesViewModelFactory
        .getViewModelByType<ChatScreenViewModel>()!
        .dialogs
        .firstWhere((d) => d.chatId == chatId);

    final messages = await tryLoginAndRetrieveData<PaginatedResult<Message>>(
      () async => await _messagesAggregator.fetch(chatId: chatId),
      () => null,
    );
    if (messages == null) {
      _hasError = true;
      return;
    }
    await _readMessages(chatId, messages);

    _unpartitionedMessages.addAll(messages.items.reversed);
    _messages.addAll(_partitionMessages(messages.items.reversed));
    _hasMessagesBefore = messages.hasPreviousPage;
    _hasMessagesAfter = messages.hasNextPage;

    refreshLoop();
  }

  List<List<List<Message>>> _partitionMessages(Iterable<Message> messages) {
    const maxTimeDifference = 5;
    final List<List<List<Message>>> partitions = [];
    for (final message in messages) {
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
          message.messageStatus != MessageState.system) {
        lastPartititon?.add(message);
        continue;
      }
      lastDatePartition?.add([message]);
    }

    return partitions;
  }

  Future<void> _readMessages(
    int chatId,
    PaginatedResult<Message> messages,
  ) async {
    await _messagesAggregator.readMessages(
      chatId: chatId,
      messageIds: messages.items.map((m) => m.messageId),
    );
  }

  FutureOr<bool> _sendMessageWrapper<T>(
    FutureOr<T?> Function() sendFunction,
  ) async =>
      await typedBusyCallAsync<bool>(() async {
        if (_dialog == null) {
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
