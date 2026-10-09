import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_style.dart';

class GradeSubjectCard extends StatefulWidget {
  final MarkBySubject mark;

  const GradeSubjectCard({required this.mark, super.key});

  @override
  State<GradeSubjectCard> createState() => _GradeSubjectCardState();
}

class _GradeSubjectCardState extends State<GradeSubjectCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mark = widget.mark;
    final color = theme.getColorOfMarkType(mark.markType);
    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            child: InkWell(
              onTap: () {
                triggerHaptic(HapticIntensity.light);
                setState(() => _expanded = !_expanded);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mark.subject,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(height: 1.35),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${DateFormat('dd.MM.yyyy').format(mark.date)} · ${mark.controlType}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Semantics(
                      label: 'Оценка: ${mark.markType.label}',
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 0.25,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          gradeLabel(mark.markType),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        const Divider(height: 1),
                        _SubjectDetail(
                          label: 'Преподаватель',
                          value: mark.lecturers?.trim().isNotEmpty ?? false
                              ? mark.lecturers!
                              : '—',
                        ),
                        _SubjectDetail(
                          label: 'Трудоёмкость',
                          value: mark.hours > 0
                              ? '${mark.hours} ч · ${mark.creditedHours} з. е.'
                              : '—',
                        ),
                        _SubjectDetail(
                          label: 'Форма контроля',
                          value: mark.controlType.trim().isEmpty
                              ? '—'
                              : mark.controlType,
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _SubjectDetail extends StatelessWidget {
  final String label;
  final String value;

  const _SubjectDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final theme = Theme.of(context);
            final title = Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            );
            final content = Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            );
            return constraints.maxWidth < 300 ||
                    MediaQuery.textScalerOf(context).scale(14) > 21
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 4),
                      SizedBox(width: double.infinity, child: content),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: title),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: content,
                        ),
                      ),
                    ],
                  );
          },
        ),
      );
}
