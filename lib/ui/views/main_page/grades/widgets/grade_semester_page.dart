// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grade_semester_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_semester_summary.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_subject_card.dart';

class GradeSemesterPage extends StatefulWidget {
  final GradeSemesterViewModel model;
  final Future<void> Function() onRefresh;

  const GradeSemesterPage({
    required this.model,
    required this.onRefresh,
    super.key,
  });

  @override
  State<GradeSemesterPage> createState() => _GradeSemesterPageState();
}

class _GradeSemesterPageState extends State<GradeSemesterPage> {
  final _scroll =
      AutoScrollController(axis: Axis.vertical, suggestedRowHeight: 100);

  Future<void> _scrollToSubject(MarkBySubject mark) async {
    final index = widget.model.semester.marks.indexOf(mark);
    if (index < 0 || !_scroll.hasClients) {
      return;
    }
    await _scroll.scrollToIndex(
      index + 1,
      preferPosition: AutoScrollPosition.begin,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semester = widget.model.semester;
    return RefreshIndicator.adaptive(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        key: PageStorageKey('grade-semester-${semester.number}'),
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: AutoScrollTag(
                key: ValueKey('grade-summary-${semester.number}'),
                controller: _scroll,
                index: 0,
                child: GradeSemesterSummary(
                  model: widget.model,
                  onSubjectSelected: _scrollToSubject,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'ДИСЦИПЛИНЫ',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          if (semester.marks.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'В этом семестре пока нет оценок',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: semester.marks.length,
                itemBuilder: (context, index) => AutoScrollTag(
                  key: ObjectKey(semester.marks[index]),
                  controller: _scroll,
                  index: index + 1,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GradeSubjectCard(mark: semester.marks[index]),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
