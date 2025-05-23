// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_fetcher_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_file_sender_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_reader_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_remover_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_sender_service.dart';
import 'package:unn_mobile/core/aggregators/intefaces/message_service_aggregator.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_updater_service.dart';

class MessageServiceAggregatorImpl implements MessageServiceAggregator {
  final MessageFetcherService _fetcherService;
  final MessageSenderService _senderService;
  final MessageUpdaterService _updaterService;
  final MessageRemoverService _removerService;
  final MessageFileSenderService _fileSenderService;
  final MessageReaderService _readerService;

  MessageServiceAggregatorImpl(
    this._fetcherService,
    this._senderService,
    this._updaterService,
    this._removerService,
    this._fileSenderService,
    this._readerService,
  );

  @override
  Future<PaginatedResult<Message>?> fetch({
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
  Future<int?> reply({
    required String dialogId,
    required String text,
    required int replyMessageId,
  }) =>
      _senderService.reply(
        dialogId: dialogId,
        text: text,
        replyMessageId: replyMessageId,
      );

  @override
  Future<int?> forward({
    required String dialogId,
    required String? text,
    required int forwardMessageId,
  }) =>
      _senderService.forward(
        dialogId: dialogId,
        text: text,
        forwardMessageId: forwardMessageId,
      );

  @override
  Future<int?> forwardMultiple({
    required String dialogId,
    required String? text,
    required List<int> forwardMessageIds,
  }) =>
      _senderService.forwardMultiple(
        dialogId: dialogId,
        text: text,
        forwardMessageIds: forwardMessageIds,
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

  @override
  Future<bool> remove({required int messageId}) =>
      _removerService.remove(messageId: messageId);

  @override
  Future<FileData?> sendFile({
    required int chatId,
    required File file,
    String? text,
  }) =>
      _fileSenderService.sendFile(
        chatId: chatId,
        file: file,
        text: text,
      );

  @override
  Future<List<FileData>?> sendFiles({
    required int chatId,
    required List<File> files,
    String? text,
  }) =>
      _fileSenderService.sendFiles(
        chatId: chatId,
        files: files,
        text: text,
      );

  @override
  Future<bool> readMessage({required int chatId, required int messageId}) =>
      _readerService.readMessage(
        chatId: chatId,
        messageId: messageId,
      );

  @override
  Future<bool> readMessages({
    required int chatId,
    required Iterable<int> messageIds,
  }) =>
      _readerService.readMessages(
        chatId: chatId,
        messageIds: messageIds,
      );
}
