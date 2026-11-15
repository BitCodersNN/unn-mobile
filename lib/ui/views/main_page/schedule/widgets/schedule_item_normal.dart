// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/widgets/lessons/lesson_card.dart';
import 'package:unn_mobile/ui/widgets/lessons/lesson_detail.dart';
import 'package:unn_mobile/ui/widgets/lessons/lesson_time_range.dart';
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
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 360),
        reverseDuration: const Duration(milliseconds: 360),
        sizeCurve: Curves.easeInOutCubic,
        firstCurve: Curves.easeInOut,
        secondCurve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        crossFadeState: _expanded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: _buildCard(context, expanded: false),
        secondChild: _buildCard(context, expanded: true),
      ),
    ),
  );

  Widget _buildCard(BuildContext context, {required bool expanded}) {
    final theme = Theme.of(context);
    final subjectType = widget.subject.subjectTypeEnum;
    final typeColor = theme.getColorOfSubjectType(subjectType);
    const verticalPadding = 4.0;
    const horizontalPadding = 8.0;

    return LessonCard(
      backgroundColor: theme.getScheduleSurfaceColor(
        widget.subject.dateTimeRange,
        isEven: widget.even,
      ),
      accentColor: typeColor,
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
                  LessonDetail(
                    icon: Icons.location_on,
                    text:
                        '${widget.subject.address.auditorium}/${widget.subject.address.building}',
                    expanded: expanded,
                  ),
                  if (expanded)
                    LessonDetail(
                      icon: Icons.person,
                      text: widget.subject.lecturer,
                      expanded: expanded,
                    ),
                  if (expanded)
                    LessonDetail(
                      icon: Icons.school,
                      text: 'Поток: ${widget.subject.groups.join('|')}',
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
            child: LessonTimeRange(range: widget.subject.dateTimeRange),
          ),
        ],
      ),
    );
  }
}
