// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grades_screen_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_semester_page.dart';

class GradeBookContent extends StatefulWidget {
  final GradesScreenViewModel model;
  final Future<void> Function() onRefresh;

  const GradeBookContent({
    required this.model,
    required this.onRefresh,
    super.key,
  });

  @override
  State<GradeBookContent> createState() => _GradeBookContentState();
}

class _GradeBookContentState extends State<GradeBookContent>
    with TickerProviderStateMixin {
  late TabController _tabs;
  late List<int> _semesterNumbers;

  @override
  void initState() {
    super.initState();
    _syncSemesterNumbers();
    _tabs = _createTabs();
  }

  void _syncSemesterNumbers() {
    _semesterNumbers =
        widget.model.semesters.map((model) => model.semester.number).toList();
  }

  TabController _createTabs() => TabController(
        length: _semesterNumbers.length,
        initialIndex: widget.model.selectedSemesterIndex,
        vsync: this,
      )..addListener(_selectSemester);

  void _selectSemester() {
    widget.model.selectSemester(_semesterNumbers[_tabs.index]);
  }

  @override
  void didUpdateWidget(GradeBookContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSemesterNumbers();
    if (_tabs.length != _semesterNumbers.length) {
      _tabs.dispose();
      _tabs = _createTabs();
    } else if (_tabs.index != widget.model.selectedSemesterIndex) {
      _tabs.index = widget.model.selectedSemesterIndex;
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
              for (final model in widget.model.semesters)
                Tab(
                  height: MediaQuery.textScalerOf(context).scale(44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Семестр ${model.semester.number}'),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              for (final model in widget.model.semesters)
                GradeSemesterPage(
                  key: ValueKey(model.semester.number),
                  model: model,
                  onRefresh: widget.onRefresh,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
