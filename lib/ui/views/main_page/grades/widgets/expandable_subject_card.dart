// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/widgets/expandable_card.dart';

class ExpandableSubjectCard extends StatelessWidget {
  final String subject;
  final String caption;
  final Widget? trailing;
  final List<Widget> details;

  const ExpandableSubjectCard({
    required this.subject,
    required this.caption,
    required this.details,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpandableCard(
      hapticIntensity: HapticIntensity.light,
      headerCrossAxisAlignment: CrossAxisAlignment.start,
      chevronSize: 20,
      chevronSpacing: 8,
      showTapHighlight: true,
      trailing: trailing,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: theme.textTheme.titleSmall?.copyWith(height: 1.35),
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              caption,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      child: Column(children: [const Divider(height: 1), ...details]),
    );
  }
}
