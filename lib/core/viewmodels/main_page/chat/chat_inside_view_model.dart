import 'dart:async';

import 'package:unn_mobile/core/aggregators/intefaces/message_service_aggregator.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
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

  int? get currentUserId => _currentUserSyncStorage.currentUserData?.bitrixId;

  Dialog? _dialog;

  bool _hasError = false;

  bool get hasError => _hasError;

  Dialog? get dialog => _dialog;

  final List<List<List<Message>>> _messages = [];

  final List<Message> _unpartitionedMessages = [];

  bool _hasMessagesBefore = false;
  bool _hasMessagesAfter = false;

  bool get hasMessagesBefore => _hasMessagesBefore;
  bool get hasMessagesAfter => _hasMessagesAfter;

  Iterable<Iterable<Iterable<Message>>> get messages => _messages;

  ChatInsideViewModel(
    this._routesViewModelFactory,
    this._messagesAggregator,
    this._currentUserSyncStorage,
  );

  FutureOr<void> init(int chatId) async {
    await busyCallAsync(() => _init(chatId));
  }

  FutureOr<void> _init(int chatId) async {
    _hasError = false;
    _hasMessagesBefore = false;
    _hasMessagesAfter = false;
    _messages.clear();
    _dialog = _routesViewModelFactory
        .getViewModelByType<ChatScreenViewModel>()!
        .dialogs
        .firstWhere((d) => d.chatId == chatId);

    final messages = await _messagesAggregator.fetch(chatId: chatId);
    if (messages == null) {
      _hasError = true;
      return;
    }
    _unpartitionedMessages.addAll(messages.items.reversed);
    _messages.addAll(_partitionMessages(messages.items.reversed));
    _hasMessagesBefore = messages.hasPreviousPage;
    _hasMessagesAfter = messages.hasNextPage;
  }

  FutureOr<void> loadMoreMessages() async => await busyCallAsync(() async {
        if (_dialog == null) {
          return;
        }
        if (!_hasMessagesBefore) {
          return;
        }
        final messages = await _messagesAggregator.fetch(
          chatId: _dialog!.chatId,
          lastMessageId: _unpartitionedMessages.last.messageId,
        );
        if (messages == null) {
          _hasError = true;
          return;
        }
        _unpartitionedMessages.addAll(messages.items.reversed);
        _messages.clear();
        _messages.addAll(_partitionMessages(_unpartitionedMessages));
        _hasMessagesBefore = messages.hasPreviousPage;
      });

  List<List<List<Message>>> _partitionMessages(Iterable<Message> messages) {
    const maxTimeDifference = 5;
    final List<List<List<Message>>> partitions = [];
    for (final message in messages) {
      final lastDatePartition = partitions.lastOrNull;
      final lastPartititon = lastDatePartition?.lastOrNull;
      final lastMessage = lastPartititon?.lastOrNull;

      final lastMessageAuthorId = lastMessage?.author?.bitrixId ?? -2;
      final messageAuthorId = message.author?.bitrixId;
      final timeDifference = //
          lastMessage //
                  ?.dateTime //
                  .difference(message.dateTime) //
                  .inMinutes
                  .abs() ??
              maxTimeDifference; // черт побери этот автоформат >:(
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
}
