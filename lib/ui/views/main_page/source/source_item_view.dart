// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:unn_mobile/core/viewmodels/main_page/source/source_item_view_model.dart';
import 'package:unn_mobile/ui/functions.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/files/file_attachment_tile.dart';
import 'package:unn_mobile/ui/widgets/link_action.dart';
import 'package:unn_mobile/ui/widgets/linkified_text.dart';

class SourceItemView extends StatelessWidget {
  final SourceItemViewModel model;
  const SourceItemView({required this.model, super.key});

  @override
  Widget build(BuildContext context) => BaseView<SourceItemViewModel>(
    model: model,
    builder: (context, model, _) {
      final theme = Theme.of(context);
      final colors = theme.colorScheme;
      final url = model.link;
      final extension = path
          .extension(model.fileName ?? '')
          .replaceFirst('.', '');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (model.comment.trim().isNotEmpty) ...[
            LinkifiedText(
              text: model.comment,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
          ],
          if (model.isFile)
            Semantics(
              button: true,
              label: 'Скачать ${model.fileName}',
              child: GestureDetector(
                onTap: model.isBusy ? null : () => model.downloadFile(),
                child: FileAttachmentTile(
                  name: model.fileName ?? 'Файл',
                  extension: extension,
                  sizeText: model.fileSize ?? '',
                  isDownloading: model.isBusy,
                ),
              ),
            )
          else if (url != null && url.isNotEmpty)
            LinkAction(
              url: url,
              label: model.comment.isNotEmpty ? model.comment : url,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link_rounded, color: colors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        url,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
    onModelReady: (model) {
      model.onFileDownloaded = (file) async {
        if (context.mounted) {
          await viewFileAndShowMessage(context, file, 'Файл сохранён');
        }
      };
    },
    onDispose: (model) => model.onFileDownloaded = null,
  );
}
