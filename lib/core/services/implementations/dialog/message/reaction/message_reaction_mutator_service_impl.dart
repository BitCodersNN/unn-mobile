// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/authenticated_api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/reaction/message_reaction_mutator_service.dart';

class _DataKeys {
  static const String sessid = 'sessid';
  static const String messageId = 'messageId';
  static const String reaction = 'reaction';
}

class MessageReactionMutatorServiceImpl
    implements MessageReactionMutatorService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  MessageReactionMutatorServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<bool> addReaction(
    int messageId,
    ReactionType reactionType,
  ) =>
      _handleReaction(
        messageId,
        reactionType,
        ApiPath.messageReactionsAdd,
      );

  @override
  Future<bool> removeReaction(
    int messageId,
    ReactionType reactionType,
  ) =>
      _handleReaction(
        messageId,
        reactionType,
        ApiPath.messageReactionsDelete,
      );

  Future<bool> _handleReaction(
    int messageId,
    ReactionType reactionType,
    String apiPath,
  ) async {
    try {
      await _apiHelper.post(
        path: apiPath,
        data: {
          _DataKeys.sessid: (_apiHelper as AuthenticatedApiHelper).sessionId,
          _DataKeys.messageId: messageId,
          _DataKeys.reaction: reactionType.name,
        },
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          10,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return false;
    }

    return true;
  }
}
