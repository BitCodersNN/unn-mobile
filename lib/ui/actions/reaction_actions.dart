// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/action_result.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';
import 'package:unn_mobile/ui/actions/ui_action_handler.dart';

class ReactionActions {
  static const String _errorMessage = 'Не удалось изменить реакцию';

  final UiActionHandler _handler;
  final ReactionViewModelBase _model;

  ReactionActions.of(BuildContext context, this._model)
    : _handler = UiActionHandler.of(context);

  Future<ActionResult> toggleLike() =>
      _handler.run(_model.toggleLike, errorMessage: _errorMessage);

  Future<ActionResult> toggleReaction(ReactionType reaction) => _handler.run(
    () => _model.toggleReaction(reaction),
    errorMessage: _errorMessage,
  );
}
