// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_lesson_progress.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleItemNormal extends StatefulWidget {
  final Subject subject;
  final bool even;
  const ScheduleItemNormal({
    required this.subject,
    super.key,
    this.even = false,
  });

  @override
  State<ScheduleItemNormal> createState() => _ScheduleItemNormalState();
}

class _ScheduleItemNormalState extends State<ScheduleItemNormal> {
  bool _expanded = false;
  final vutsScheduleUri = 'http://www.ivo.unn.ru/raspisanie-vuts/';

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
    child: GestureDetector(
      onTap: () async {
        if (widget.subject.name == 'Военная подготовка') {
          final Uri url = Uri.parse(vutsScheduleUri);
          if (!await launchUrl(url)) {
            throw Exception('Could not launch $url');
          }
        } else {
          setState(() {
            _expanded = !_expanded;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.even
              ? Theme.of(context).colorScheme.primary.withAlpha(20)
              : Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(12),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ScheduleLessonProgress(
          range: widget.subject.dateTimeRange,
          color: Theme.of(context)
              .getColorOfSubjectType(widget.subject.subjectTypeEnum),
          endTime: _endTime(Theme.of(context)),
          builder: ({required hasTimeBadge}) => AnimatedCrossFade(
            duration: const Duration(milliseconds: 360),
            reverseDuration: const Duration(milliseconds: 360),
            sizeCurve: Curves.easeInOutCubic,
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _buildCard(
              context,
              expanded: false,
              hasTimeBadge: hasTimeBadge,
            ),
            secondChild: _buildCard(
              context,
              expanded: true,
              hasTimeBadge: hasTimeBadge,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildCard(
    BuildContext context, {
    required bool expanded,
    required bool hasTimeBadge,
  }) {
    final theme = Theme.of(context);
    final DateFormat timeFormatter = DateFormat('HH:mm');
    final subjectType = widget.subject.subjectTypeEnum;
    final typeColor = theme.getColorOfSubjectType(subjectType);
    const verticalPadding = 4.0;
    const horizontalPadding = 8.0;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: verticalPadding,
                horizontal: horizontalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subject.name,
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: expanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  _textWithIcon(
                    context,
                    Icons.location_on,
                    '${widget.subject.address.auditorium}/${widget.subject.address.building}',
                    expanded: expanded,
                  ),
                  if (expanded)
                    _textWithIcon(
                      context,
                      Icons.person,
                      widget.subject.lecturer,
                      expanded: expanded,
                    ),
                  if (expanded)
                    _textWithIcon(
                      context,
                      Icons.school,
                      'Поток: ${widget.subject.groups.join('|')}',
                      expanded: expanded,
                    ),
                  Text(
                    widget.subject.subjectType,
                    style: theme.textTheme.labelLarge!.copyWith(
                      color: typeColor,
                      fontStyle: FontStyle.italic,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeFormatter.format(widget.subject.dateTimeRange.start),
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: hasTimeBadge
                      ? const SizedBox.shrink()
                      : _endTime(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _endTime(ThemeData theme) => Text(
    DateFormat('HH:mm').format(widget.subject.dateTimeRange.end),
    style: theme.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.extension<UnnMobileColors>()!.ligtherTextColor,
    ),
  );

  Widget _textWithIcon(
    BuildContext context,
    IconData icon,
    String text, {
    required bool expanded,
  }) {
    final theme = Theme.of(context);
    final extraColors = theme.extension<UnnMobileColors>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0, right: 4.0),
          child: Icon(
            icon,
            color: extraColors.ligtherTextColor,
            applyTextScaling: true,
            size: 16,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.labelLarge!.copyWith(
              color: extraColors.ligtherTextColor,
            ),
            overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            softWrap: expanded,
          ),
        ),
      ],
    );
  }
}
