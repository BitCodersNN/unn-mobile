// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

class FileAttachmentTile extends StatelessWidget {
  final String name;
  final String extension;
  final String sizeText;
  final IconData icon;
  final bool isLoading;
  final bool isDownloading;
  final bool useCardStyle;

  const FileAttachmentTile({
    required this.name,
    required this.extension,
    required this.sizeText,
    this.icon = Icons.description,
    this.isLoading = false,
    this.isDownloading = false,
    this.useCardStyle = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extraColors = theme.extension<UnnMobileColors>();
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);
    final content = Row(
      children: [
        ShimmerLoading(
          isLoading: isLoading,
          child: useCardStyle
              ? Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _fileColor(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                )
              : Icon(icon, size: 30, color: theme.primaryColorLight),
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
                      isLoading: isLoading,
                      child: isLoading
                          ? Container(
                              width: double.infinity,
                              height: scaler.scale(20),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            )
                          : Text(
                              useCardStyle ? name : path.withoutExtension(name),
                              overflow: TextOverflow.ellipsis,
                              textScaler: scaler,
                              style: useCardStyle
                                  ? theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    )
                                  : const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  if (!isLoading && isDownloading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
              Text(
                useCardStyle
                    ? '${extension.toUpperCase()} · $sizeText'
                    : '$extension | $sizeText',
                style: TextStyle(
                  color: useCardStyle
                      ? theme.colorScheme.onSurfaceVariant
                      : extraColors?.ligtherTextColor,
                  fontSize: useCardStyle ? 11 : null,
                ),
              ),
            ],
          ),
        ),
        if (useCardStyle) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.download_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ],
      ],
    );
    return Container(
      padding: useCardStyle ? const EdgeInsets.all(12) : EdgeInsets.zero,
      color: useCardStyle ? null : Colors.transparent,
      decoration: useCardStyle
          ? BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            )
          : null,
      child: isLoading ? Shimmer(child: content) : content,
    );
  }

  Color _fileColor(BuildContext context) => switch (extension.toLowerCase()) {
    'pdf' => const Color(0xFFE5484D),
    'doc' || 'docx' => const Color(0xFF2F6DD6),
    'xls' || 'xlsx' || 'csv' => const Color(0xFF1C9459),
    'zip' || 'rar' || '7z' => const Color(0xFF8E5FC1),
    _ => Theme.of(context).colorScheme.primary,
  };
}
