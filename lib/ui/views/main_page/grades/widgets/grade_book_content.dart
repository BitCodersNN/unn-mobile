// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/grade_book/grade_book_summary.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_semester_page.dart';

class GradeBookContent extends StatefulWidget {
  final GradeBookSummary summary;
  final Future<void> Function() onRefresh;

  const GradeBookContent({
    required this.summary,
    required this.onRefresh,
    super.key,
  });

  @override
  State<GradeBookContent> createState() => _GradeBookContentState();
}

class _GradeBookContentState extends State<GradeBookContent>
    with TickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: widget.summary.semesters.length,
      initialIndex: widget.summary.semesters.length - 1,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(GradeBookContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedSemester = oldWidget.summary.semesters[_tabs.index].number;
    final semesters = widget.summary.semesters;
    if (_tabs.length != semesters.length) {
      _tabs.dispose();
      final index = semesters
          .indexWhere((semester) => semester.number == selectedSemester);
      _tabs = TabController(
        length: semesters.length,
        initialIndex: index < 0 ? semesters.length - 1 : index,
        vsync: this,
      );
    } else {
      final index = semesters
          .indexWhere((semester) => semester.number == selectedSemester);
      _tabs.index = index < 0 ? semesters.length - 1 : index;
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            enableFeedback: false,
            onTap: (_) => triggerHaptic(HapticIntensity.selection),
            tabs: [
              for (final semester in widget.summary.semesters)
                Tab(
                  height: MediaQuery.textScalerOf(context).scale(44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Семестр ${semester.number}'),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              for (final semester in widget.summary.semesters)
                GradeSemesterPage(
                  key: ValueKey(semester.number),
                  semester: semester,
                  overall: widget.summary.overall,
                  onRefresh: widget.onRefresh,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
