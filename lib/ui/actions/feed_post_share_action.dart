// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/feed/feed_post_share_preparer.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/ui/actions/share_utils.dart';

/// Открывает системную отправку текста поста вместе с доступными вложениями.
Future<void> shareFeedPost(BuildContext context, FeedPostViewModel post) {
  final id = post.blogData?.id;
  if (id == null) {
    return Future.value();
  }
  return runGuardedShare(
    context: context,
    errorMessage: 'Не удалось поделиться постом',
    action: (logger) => _shareFeedPost(context, post, logger),
  );
}

Future<void> _shareFeedPost(
  BuildContext context,
  FeedPostViewModel post,
  LoggerService logger,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final preparation = _SharePreparationIndicator.show(messenger);
  triggerHaptic(HapticIntensity.light);
  try {
    await _prepareAndShare(context, post, logger, preparation.close);
  } finally {
    preparation.close();
  }
}

Future<void> _prepareAndShare(
  BuildContext context,
  FeedPostViewModel post,
  LoggerService logger,
  VoidCallback onPrepared,
) async {
  final origin = resolveSharePositionOrigin(context);
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
  await shareContent(origin: origin, text: content.text, files: content.files);
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

class _SharePreparationIndicator {
  final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _controller;
  bool _closed;

  _SharePreparationIndicator._(this._controller)
    : _closed = _controller == null {
    unawaited(_controller?.closed.then(_markClosed));
  }

  factory _SharePreparationIndicator.show(ScaffoldMessengerState? messenger) {
    messenger?.clearSnackBars();
    messenger?.removeCurrentSnackBar();
    return _SharePreparationIndicator._(
      messenger?.showSnackBar(
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
      ),
    );
  }

  void _markClosed(SnackBarClosedReason _) {
    _closed = true;
  }

  void close() {
    if (_closed) {
      return;
    }
    _closed = true;
    _controller?.close();
  }
}
