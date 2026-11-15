// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/attached_file_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/files/file_attachment_tile.dart';
import 'package:unn_mobile/ui/widgets/image_viewer_screen.dart';

class AttachedFiles extends StatelessWidget {
  final Iterable<AttachedFileViewModel> files;
  final bool useCardStyle;

  const AttachedFiles({
    required this.files,
    this.useCardStyle = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) => files.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              for (final file in files)
                AttachedFile(viewModel: file, useCardStyle: useCardStyle),
            ],
          ),
        );
}

class AttachedFile extends StatefulWidget {
  final AttachedFileViewModel viewModel;
  final bool useCardStyle;
  const AttachedFile({
    required this.viewModel,
    super.key,
    this.useCardStyle = false,
  });

  @override
  State<AttachedFile> createState() => _AttachedFileState();
}

class _AttachedFileState extends State<AttachedFile> {
  @override
  Widget build(BuildContext context) => BaseView<AttachedFileViewModel>(
    model: widget.viewModel,
    builder: (context, model, _) {
      final iconData = _iconDataByFileType(model);
      return SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onTap: () async {
            await _downloadAndOpenFile(model, false, context);
          },
          onLongPress: () async {
            triggerHaptic(HapticIntensity.medium);
            await Future.wait([
              _downloadAndOpenFile(model, true, context),
              FirebaseAnalytics.instance.logEvent(
                name: 'feed_attached_file_long_press',
              ),
            ]);
          },
          child: FileAttachmentTile(
            name: model.fileName,
            extension: model.fileExtension,
            sizeText: model.fileSizeText,
            icon: iconData,
            isLoading: model.isLoadingData,
            isDownloading: model.isDownloadingFile,
            useCardStyle: widget.useCardStyle,
          ),
        ),
      );
    },
  );

  Future<void> _downloadAndOpenFile(
    AttachedFileViewModel model,
    bool force,
    BuildContext context,
  ) async {
    if (model.isLoadingData || model.isDownloadingFile) {
      return;
    }
    if (!force) {
      triggerHaptic(HapticIntensity.light);
    }
    final file = await model.getFile(force: force);
    if (file == null) {
      return;
    }
    if (context.mounted) {
      await _openFile(model, context, file);
    }
  }

  Future<void> _openFile(
    AttachedFileViewModel model,
    BuildContext context,
    File file,
  ) async {
    switch (model.fileType) {
      case AttachedFileType.image:
      case AttachedFileType.gif:
        if (context.mounted) {
          await showImageViewer(context, images: [FileImage(file)]);
        }
        break;
      default:
        final openResult = await OpenFilex.open(file.path);
        switch (openResult.type) {
          case ResultType.error:
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Неизвестная ошибка')),
              );
            }
            break;
          case ResultType.noAppToOpen:
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Нет подходящей программы')),
              );
            }
            break;
          case ResultType.permissionDenied:
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Нет доступа к файлам')),
              );
            }
            break;
          default:
            break;
        }
        break;
    }
  }

  IconData _iconDataByFileType(AttachedFileViewModel model) {
    final IconData iconData;
    switch (model.fileType) {
      case AttachedFileType.image:
        iconData = Icons.image;
        break;
      case AttachedFileType.audio:
        iconData = Icons.headset;
        break;
      case AttachedFileType.gif:
        iconData = Icons.gif;
        break;
      default:
        iconData = Icons.description;
        break;
    }
    return iconData;
  }
}
