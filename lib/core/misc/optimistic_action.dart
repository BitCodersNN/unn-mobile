// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/models/common/action_result.dart';

class OptimisticAction {
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<ActionResult> run({
    required void Function() apply,
    required Future<bool> Function() save,
    required FutureOr<void> Function() rollback,
    required void Function() onChanged,
    required void Function(Object, StackTrace) onError,
    FutureOr<void> Function()? commit,
  }) async {
    if (_isRunning) {
      return ActionResult.skipped;
    }
    _isRunning = true;
    try {
      return await _execute(apply, save, rollback, commit, onChanged, onError);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      await _completeSafely(rollback, onError);
      return ActionResult.failure;
    } finally {
      _isRunning = false;
      onChanged();
    }
  }

  Future<ActionResult> _execute(
    void Function() apply,
    Future<bool> Function() save,
    FutureOr<void> Function() rollback,
    FutureOr<void> Function()? commit,
    void Function() onChanged,
    void Function(Object, StackTrace) onError,
  ) async {
    apply();
    onChanged();
    if (!await save()) {
      await _completeSafely(rollback, onError);
      return ActionResult.failure;
    }
    if (commit != null) {
      await _completeSafely(commit, onError);
    }
    return ActionResult.success;
  }

  Future<void> _completeSafely(
    FutureOr<void> Function() complete,
    void Function(Object, StackTrace) onError,
  ) async {
    try {
      await complete();
    } catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }
}
