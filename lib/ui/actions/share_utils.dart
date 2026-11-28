// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

Future<void>? _pendingShare;

/// Вычисляет область экрана для позиционирования системного окна «Поделиться».
Rect resolveSharePositionOrigin(BuildContext context) {
  final screen = Offset.zero & MediaQuery.sizeOf(context);
  final renderObject = context.findRenderObject();
  final rect = renderObject is RenderBox && renderObject.hasSize
      ? (renderObject.localToGlobal(Offset.zero) & renderObject.size).intersect(
          screen,
        )
      : Rect.zero;
  return rect.isEmpty
      ? Rect.fromCenter(center: screen.center, width: 1, height: 1)
      : rect;
}

/// Защищает системную отправку от повторного запуска, логирует ошибки и показывает SnackBar при сбое.
Future<void> runGuardedShare({
  required BuildContext context,
  required String errorMessage,
  required Future<void> Function(LoggerService logger) action,
}) => _pendingShare ??=
    _executeGuardedShare(
      context: context,
      errorMessage: errorMessage,
      action: action,
    ).whenComplete(() {
      _pendingShare = null;
    });

Future<void> _executeGuardedShare({
  required BuildContext context,
  required String errorMessage,
  required Future<void> Function(LoggerService logger) action,
}) async {
  final logger = Injector.appInstance.get<LoggerService>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    await action(logger);
  } catch (error, stack) {
    logger.logError(error, stack);
    if (messenger != null && messenger.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}

/// Открывает системное окно «Поделиться» для текста и опциональных файлов.
Future<void> shareContent({
  required Rect origin,
  String? text,
  List<XFile>? files,
}) => SharePlus.instance.share(
  ShareParams(
    text: text,
    files: files == null || files.isEmpty ? null : files,
    sharePositionOrigin: origin,
  ),
);
