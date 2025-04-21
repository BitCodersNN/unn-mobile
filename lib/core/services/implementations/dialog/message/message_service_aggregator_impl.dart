import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_fetcher_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_sender_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_service_aggregator.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_updater_service.dart';

class MessageServiceAggregatorImpl implements MessageServiceAggregator {
  final MessageFetcherService _fetcherService;
  final MessageSenderService _senderService;
  final MessageUpdaterService _updaterService;

  MessageServiceAggregatorImpl(
    this._fetcherService,
    this._senderService,
    this._updaterService,
  );

  @override
  Future<PaginatedResult?> fetch({
    required int chatId,
    int limit = 25,
    int? lastMessageId,
  }) =>
      _fetcherService.fetch(
        chatId: chatId,
        limit: limit,
        lastMessageId: lastMessageId,
      );

  @override
  Future<int?> send({
    required String dialogId,
    required String text,
  }) =>
      _senderService.send(
        dialogId: dialogId,
        text: text,
      );

  @override
  Future<bool> update({
    required int messageId,
    required String text,
  }) =>
      _updaterService.update(
        messageId: messageId,
        text: text,
      );
}
