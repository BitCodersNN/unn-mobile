// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/services/interfaces/feed/legacy/getting_rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/feed/legacy/getting_vote_key_signed.dart';
import 'package:unn_mobile/core/services/interfaces/feed/reaction_service.dart';
import 'package:unn_mobile/core/viewmodels/factories/cached_view_model_factory_base.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/reaction_view_model.dart';

typedef ReactionCacheKey = int;

class ReactionViewModelFactory
    extends CachedViewModelFactoryBase<ReactionCacheKey, ReactionViewModel> {
  ReactionViewModelFactory() : super(100);

  @override
  @protected
  ReactionViewModel createViewModel(key) {
    return ReactionViewModel(
      getService<GettingVoteKeySigned>(),
      getService<GettingRatingList>(),
      getService<ReactionService>(),
      getService<CurrentUserSyncStorage>(),
    );
  }
}
