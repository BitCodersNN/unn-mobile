import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:unn_mobile/core/models/grade_book/curriculum_semester.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grade_semester_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_semester_summary.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_subject_card.dart';

class CurriculumSemesterPage extends StatefulWidget {
  final int number;
  final CurriculumSemester curriculum;
  final GradeSemesterViewModel? summary;
  final Future<void> Function() onRefresh;

  const CurriculumSemesterPage({
    required this.number,
    required this.curriculum,
    required this.onRefresh,
    this.summary,
    super.key,
  });

  @override
  State<CurriculumSemesterPage> createState() => _CurriculumSemesterPageState();
}

class _CurriculumSemesterPageState extends State<CurriculumSemesterPage> {
  final AutoScrollController _scroll =
      AutoScrollController(axis: Axis.vertical, suggestedRowHeight: 100);

  Future<void> _scrollToSubject(MarkBySubject subject) async {
    final subjects = [
      ...widget.curriculum.mandatorySubjects,
      ...widget.curriculum.electiveSubjects,
    ];
    final index = subjects.indexOf(subject);
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
  Widget build(BuildContext context) => RefreshIndicator.adaptive(
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          key: PageStorageKey('curriculum-semester-${widget.number}'),
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (widget.summary != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: AutoScrollTag(
                    key: ValueKey('curriculum-summary-${widget.number}'),
                    controller: _scroll,
                    index: 0,
                    child: GradeSemesterSummary(
                      model: widget.summary!,
                      onSubjectSelected: _scrollToSubject,
                    ),
                  ),
                ),
              ),
            if (widget.curriculum.mandatorySubjects.isEmpty &&
                widget.curriculum.electiveSubjects.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'В этом семестре пока нет дисциплин учебного плана',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            if (widget.curriculum.mandatorySubjects.isNotEmpty)
              _CurriculumGroup(
                title: 'ОБЯЗАТЕЛЬНАЯ ЧАСТЬ',
                controller: _scroll,
                startIndex: 1,
                subjects: widget.curriculum.mandatorySubjects,
              ),
            if (widget.curriculum.electiveSubjects.isNotEmpty)
              _CurriculumGroup(
                title: 'ДИСЦИПЛИНЫ ПО ВЫБОРУ',
                controller: _scroll,
                startIndex: widget.curriculum.mandatorySubjects.length + 1,
                subjects: widget.curriculum.electiveSubjects,
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      );
}

class _CurriculumGroup extends StatelessWidget {
  final String title;
  final List<MarkBySubject> subjects;
  final AutoScrollController controller;
  final int startIndex;

  const _CurriculumGroup({
    required this.title,
    required this.subjects,
    required this.controller,
    required this.startIndex,
  });

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) => AutoScrollTag(
                key: ObjectKey(subjects[index]),
                controller: controller,
                index: startIndex + index,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GradeSubjectCard(mark: subjects[index]),
                ),
              ),
            ),
          ),
        ],
      );
}
