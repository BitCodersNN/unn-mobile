// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/action_result.dart';

class UiActionHandler {
  final ScaffoldMessengerState? _messenger;

  UiActionHandler.of(BuildContext context)
    : _messenger = ScaffoldMessenger.maybeOf(context);

  Future<ActionResult> run(
    Future<ActionResult> Function() action, {
    required String errorMessage,
  }) async {
    final result = await action();
    final messenger = _messenger;
    if (result == ActionResult.failure &&
        messenger != null &&
        messenger.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
    }
    return result;
  }
}
