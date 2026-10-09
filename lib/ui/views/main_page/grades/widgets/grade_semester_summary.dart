import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/grade_book/grade_semester.dart';
import 'package:unn_mobile/core/models/grade_book/grade_statistics.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_details_popover.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_distribution_bar.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_style.dart';

enum _SummaryDetails { disciplines, exams, retakes }

class GradeSemesterSummary extends StatefulWidget {
  final GradeSemester semester;
  final GradeStatistics overall;
  final Future<void> Function(MarkBySubject)? onSubjectSelected;

  const GradeSemesterSummary({
    required this.semester,
    required this.overall,
    this.onSubjectSelected,
    super.key,
  });

  @override
  State<GradeSemesterSummary> createState() => _GradeSemesterSummaryState();
}

class _GradeSemesterSummaryState extends State<GradeSemesterSummary> {
  bool _expanded = false;

  Future<void> _toggle(GradeDetailsDismiss dismiss) async {
    triggerHaptic(HapticIntensity.light);
    await dismiss();
    if (mounted) {
      setState(() => _expanded = !_expanded);
    }
  }

  Future<void> _selectSubject(
    BuildContext context,
    GradeDetailsDismiss dismiss,
    MarkBySubject mark,
  ) async {
    await dismiss();
    if (context.mounted) {
      await widget.onSubjectSelected?.call(mark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semester = widget.semester;
    final statistics = semester.statistics;
    final difference = statistics.averageDifferenceFrom(widget.overall);
    final differenceColor = difference == null || difference == 0
        ? null
        : difference > 0
            ? theme.getColorOfMarkType(MarkType.excellent)
            : theme.getColorOfMarkType(MarkType.notSatisfactory);
    return GradeDetailsPopover(
      openBelow: true,
      builder: (popoverContext, selected, showDetails, dismiss) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              Color.lerp(
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                0.7,
              )!,
            ],
          ),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: theme.colorScheme.onPrimary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                button: true,
                expanded: _expanded,
                label: _expanded ? 'Свернуть сводку' : 'Развернуть сводку',
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    key: const ValueKey('grade-summary-toggle'),
                    borderRadius: BorderRadius.circular(12),
                    overlayColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                    onTap: () => _toggle(dismiss),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_stories_outlined,
                            color: theme.colorScheme.onPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Семестр ${semester.number}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: theme.colorScheme.onPrimary,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: _expanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final singleColumn = constraints.maxWidth < 260 ||
                                  MediaQuery.textScalerOf(context).scale(14) >
                                      21;
                              final width = singleColumn
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 8) / 2;
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _SummaryMetric(
                                    width: width,
                                    label: 'Средний за семестр',
                                    value:
                                        formatGradeAverage(statistics.average),
                                    suffix: difference == null
                                        ? null
                                        : '${difference > 0 ? '+' : ''}${NumberFormat('0.##', 'ru_RU').format(difference)}%',
                                    suffixColor: differenceColor,
                                  ),
                                  _SummaryMetric(
                                    width: width,
                                    label: 'За всё обучение',
                                    value: formatGradeAverage(
                                      widget.overall.average,
                                    ),
                                  ),
                                  _SummaryMetric(
                                    key: const ValueKey(
                                      'grade-metric-disciplines',
                                    ),
                                    width: width,
                                    label: 'Дисциплины',
                                    selected:
                                        selected == _SummaryDetails.disciplines,
                                    onTap: (anchorContext) => showDetails(
                                      anchorContext,
                                      _SummaryDetails.disciplines,
                                      _SubjectDetails(
                                        kind: _SummaryDetails.disciplines,
                                        marks: semester.marks,
                                        onSelected: (mark) => _selectSubject(
                                          popoverContext,
                                          dismiss,
                                          mark,
                                        ),
                                      ),
                                    ),
                                    value: statistics.subjectCount == 0
                                        ? '—'
                                        : '${statistics.subjectCount}',
                                  ),
                                  _SummaryMetric(
                                    key: const ValueKey('grade-metric-exams'),
                                    width: width,
                                    label: 'Экзамены',
                                    selected: selected == _SummaryDetails.exams,
                                    onTap: (anchorContext) => showDetails(
                                      anchorContext,
                                      _SummaryDetails.exams,
                                      _SubjectDetails(
                                        kind: _SummaryDetails.exams,
                                        marks: semester.exams,
                                        onSelected: (mark) => _selectSubject(
                                          popoverContext,
                                          dismiss,
                                          mark,
                                        ),
                                      ),
                                    ),
                                    value: statistics.subjectCount == 0
                                        ? '—'
                                        : '${statistics.examCount}',
                                  ),
                                  if (statistics.retakeCount > 0)
                                    _SummaryMetric(
                                      key: const ValueKey(
                                        'grade-metric-retakes',
                                      ),
                                      width: constraints.maxWidth,
                                      label: 'Требуют пересдачи',
                                      selected:
                                          selected == _SummaryDetails.retakes,
                                      onTap: (anchorContext) => showDetails(
                                        anchorContext,
                                        _SummaryDetails.retakes,
                                        _SubjectDetails(
                                          kind: _SummaryDetails.retakes,
                                          marks: semester.retakes,
                                          onSelected: (mark) => _selectSubject(
                                            popoverContext,
                                            dismiss,
                                            mark,
                                          ),
                                        ),
                                      ),
                                      value: '${statistics.retakeCount}',
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Распределение оценок',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: theme.colorScheme.onPrimary),
                          ),
                          GradeDistributionBar(
                            statistics: statistics,
                            selected: selected,
                            onShowDetails: showDetails,
                          ),
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final String? suffix;
  final Color? suffixColor;
  final ValueChanged<BuildContext>? onTap;
  final bool selected;

  const _SummaryMetric({
    required this.width,
    required this.label,
    required this.value,
    this.suffix,
    this.suffixColor,
    this.onTap,
    this.selected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onPrimary;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: selected ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: foreground.withValues(alpha: selected ? 0.7 : 0.16),
        ),
      ),
      child: Semantics(
        button: onTap != null,
        selected: selected,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap == null ? null : () => onTap!(context),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (suffix != null)
                        Container(
                          padding: suffixColor == null
                              ? EdgeInsets.zero
                              : const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                          decoration: suffixColor == null
                              ? null
                              : BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                          child: Text(
                            suffix!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: suffixColor ??
                                  foreground.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: foreground.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectDetails extends StatelessWidget {
  final _SummaryDetails kind;
  final Iterable<MarkBySubject> marks;
  final Future<void> Function(MarkBySubject) onSelected;

  const _SubjectDetails({
    required this.kind,
    required this.marks,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: ValueKey('grade-${kind.name}-details'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          switch (kind) {
            _SummaryDetails.disciplines => 'Дисциплины',
            _SummaryDetails.exams => 'Экзамены',
            _SummaryDetails.retakes => 'Требуют пересдачи',
          },
          style: theme.textTheme.titleSmall
              ?.copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        if (marks.isEmpty)
          Text(
            kind == _SummaryDetails.disciplines
                ? 'В этом семестре нет дисциплин'
                : 'В этом семестре нет экзаменов',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          )
        else
          for (final mark in marks)
            InkWell(
              key: ObjectKey(mark),
              onTap: () => onSelected(mark),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mark.subject,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      kind == _SummaryDetails.retakes
                          ? '${mark.controlType} · ${mark.markType.label}'
                          : '${gradeLabel(mark.markType)}${mark.markType.isNumeric ? ' · ${mark.markType.label}' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.getColorOfMarkType(mark.markType),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
