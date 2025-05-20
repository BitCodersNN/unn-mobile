// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/aggregators/intefaces/message_reaction_service_aggregator.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/viewmodels/factories/cached_view_model_factory_base.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/message_reaction_view_model.dart';

typedef MessageReactionCacheKey = int;

class MessageReactionViewModelFactory extends CachedViewModelFactoryBase<
    MessageReactionCacheKey, MessageReactionViewModel> {
  MessageReactionViewModelFactory() : super(100);

  @override
  MessageReactionViewModel createViewModel(MessageReactionCacheKey key) {
    return MessageReactionViewModel(
      getService<MessageReactionServiceAggregator>(),
      getService<CurrentUserSyncStorage>(),
    );
  }
}
