// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/attached_file_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/image_viewer_sheet.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extraColors = theme.extension<UnnMobileColors>();
    final scaler = MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 1.3);
    return BaseView<AttachedFileViewModel>(
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
                FirebaseAnalytics.instance
                    .logEvent(name: 'feed_attached_file_long_press'),
              ]);
            },
            child: Container(
              padding: widget.useCardStyle
                  ? const EdgeInsets.all(12)
                  : EdgeInsets.zero,
              color: widget.useCardStyle ? null : Colors.transparent,
              decoration: widget.useCardStyle
                  ? BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.6),
                      ),
                    )
                  : null,
              child: Shimmer(
                child: Row(
                  children: [
                    ShimmerLoading(
                      isLoading: model.isLoadingData,
                      child: widget.useCardStyle
                          ? Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _fileColor(model),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                iconData,
                                size: 20,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              iconData,
                              size: 30,
                              color: theme.primaryColorLight,
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ShimmerLoading(
                                  isLoading: model.isLoadingData,
                                  child: model.isLoadingData
                                      ? Container(
                                          width: double.infinity,
                                          height: scaler.scale(20),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        )
                                      : Text(
                                          widget.useCardStyle
                                              ? model.fileName
                                              : path.withoutExtension(
                                                  model.fileName,
                                                ),
                                          overflow: TextOverflow.ellipsis,
                                          textScaler: scaler,
                                          style: widget.useCardStyle
                                              ? theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                )
                                              : const TextStyle(
                                                  fontSize: 16,
                                                ),
                                        ),
                                ),
                              ),
                              if (!model.isLoadingData &&
                                  model.isDownloadingFile)
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            widget.useCardStyle
                                ? '${model.fileExtension.toUpperCase()} · ${model.fileSizeText}'
                                : '${model.fileExtension} | ${model.fileSizeText}',
                            style: TextStyle(
                              color: widget.useCardStyle
                                  ? theme.colorScheme.onSurfaceVariant
                                  : extraColors?.ligtherTextColor,
                              fontSize: widget.useCardStyle ? 11 : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.useCardStyle) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.download_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadAndOpenFile(
    AttachedFileViewModel model,
    bool force,
    BuildContext context,
  ) async {
    if (model.isLoadingData || model.isDownloadingFile) {
      return;
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
          await showImageViewerSheet(
            context,
            images: [FileImage(file)],
          );
        }
        break;
      default:
        final openResult = await OpenFilex.open(file.path);
        switch (openResult.type) {
          case ResultType.error:
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Неизвестная ошибка'),
                ),
              );
            }
            break;
          case ResultType.noAppToOpen:
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Нет подходящей программы'),
                ),
              );
            }
            break;
          case ResultType.permissionDenied:
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Нет доступа к файлам'),
                ),
              );
            }
            break;
          default:
            break;
        }
        break;
    }
  }

  Color _fileColor(AttachedFileViewModel model) =>
      switch (model.fileExtension.toLowerCase()) {
        'pdf' => const Color(0xFFE5484D),
        'doc' || 'docx' => const Color(0xFF2F6DD6),
        'xls' || 'xlsx' || 'csv' => const Color(0xFF1C9459),
        'zip' || 'rar' || '7z' => const Color(0xFF8E5FC1),
        _ => Theme.of(context).colorScheme.primary,
      };

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
