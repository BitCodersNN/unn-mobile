// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_page_view_model.dart';
import 'package:unn_mobile/ui/widgets/period_navigation.dart';

class SourceSemesterSelector extends StatelessWidget {
  final SourcePageViewModel model;
  final bool enabled;

  const SourceSemesterSelector({
    required this.model,
    required this.enabled,
    super.key,
  });

  Future<void> _selectSemester(BuildContext context) async {
    final selected = await showConfirmationDialog<int>(
      context: context,
      title: 'Выберите семестр',
      actions: [
        for (final (index, semester) in model.semesters.indexed)
          AlertDialogAction(
            key: index,
            label: semester.toString(),
            isDefaultAction: index == model.currentSemesterIndex,
          ),
      ],
      cancelLabel: 'Отмена',
      shrinkWrap: true,
      initialSelectedActionKey: model.currentSemesterIndex,
    );
    if (selected != null && context.mounted) {
      await model.setSemester(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semester = model.currentSemester;
    final index = model.currentSemesterIndex;
    final canChange = enabled && !model.isBusy && model.semesters.isNotEmpty;
    return PeriodNavigation(
      onPrevious: canChange && index != null && index > 0
          ? () => model.setSemester(index - 1)
          : null,
      onNext: canChange && index != null && index < model.semesters.length - 1
          ? () => model.setSemester(index + 1)
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: model.isBusy && semester == null
            ? const Center(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator.adaptive(),
                ),
              )
            : TextButton(
                onPressed: canChange ? () => _selectSemester(context) : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      semester == null
                          ? 'Выбрать семестр'
                          : '${semester.semester} семестр',
                      style: theme.textTheme.titleMedium,
                    ),
                    if (semester != null)
                      Text(
                        '${semester.academicYear} учебный год',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
