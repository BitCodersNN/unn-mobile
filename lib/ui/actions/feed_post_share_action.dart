// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unn_mobile/core/misc/feed/feed_post_share_preparer.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';

Future<void>? _pendingShare;

/// Открывает системную отправку текста поста вместе с доступными вложениями.
Future<void> shareFeedPost(BuildContext context, FeedPostViewModel post) {
  final id = post.blogData?.id;
  if (id == null) {
    return Future.value();
  }
  return _pendingShare ??= _shareFeedPost(context, post).whenComplete(() {
    _pendingShare = null;
  });
}

Future<void> _shareFeedPost(
  BuildContext context,
  FeedPostViewModel post,
) async {
  final logger = Injector.appInstance.get<LoggerService>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.clearSnackBars();
  messenger?.removeCurrentSnackBar();
  final preparing = messenger?.showSnackBar(
    const SnackBar(
      duration: Duration(minutes: 1),
      content: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Expanded(child: Text('Подготовка поста к отправке…')),
        ],
      ),
    ),
  );
  bool preparationClosed = preparing == null;
  unawaited(
    preparing?.closed.then((_) {
      preparationClosed = true;
    }),
  );
  void closePreparation() {
    if (!preparationClosed) {
      preparationClosed = true;
      preparing?.close();
    }
  }

  triggerHaptic(HapticIntensity.light);
  try {
    await _prepareAndShare(context, post, logger, closePreparation);
  } catch (error, stack) {
    logger.logError(error, stack);
    if (messenger != null && messenger.mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Не удалось поделиться постом')),
      );
    }
  } finally {
    closePreparation();
  }
}

Future<void> _prepareAndShare(
  BuildContext context,
  FeedPostViewModel post,
  LoggerService logger,
  VoidCallback onPrepared,
) async {
  final screen = Offset.zero & MediaQuery.sizeOf(context);
  final renderObject = context.findRenderObject();
  final rect = renderObject is RenderBox && renderObject.hasSize
      ? (renderObject.localToGlobal(Offset.zero) & renderObject.size).intersect(
          screen,
        )
      : Rect.zero;
  final origin = rect.isEmpty
      ? Rect.fromCenter(center: screen.center, width: 1, height: 1)
      : rect;
  final content = await FeedPostSharePreparer(logger).prepare(
    htmlText: post.postText,
    authorName: post.profileViewModel?.userData?.fullname,
    imageUrls: post.attachedImages,
    authorizationHeaders: post.authHeaders,
    attachments: [
      for (final file in post.attachedFileViewModels)
        (name: file.fileName, load: file.getFile),
    ],
  );
  onPrepared();
  if (!context.mounted) {
    return;
  }
  await SharePlus.instance.share(
    ShareParams(
      text: content.text,
      files: content.files.isEmpty ? null : content.files,
      sharePositionOrigin: origin,
    ),
  );
  if (content.unavailableAttachments > 0 && context.mounted) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          content.files.isEmpty
              ? 'Вложения не удалось загрузить. Доступна отправка текста.'
              : 'Часть вложений не удалось загрузить',
        ),
      ),
    );
  }
}
