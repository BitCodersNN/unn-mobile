// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
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

class _ScheduleItemNormalState extends State<ScheduleItemNormal>
    with TickerProviderStateMixin {
  bool _expanded = false;
  final vutsScheduleUri = 'http://www.ivo.unn.ru/raspisanie-vuts/';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extraColors = theme.extension<UnnMobileColors>()!;
    final DateFormat timeFormatter = DateFormat('HH:mm');
    final subjectType = widget.subject.subjectTypeEnum;
    final typeColor = theme.getColorOfSubjectType(subjectType);
    const verticalPadding = 4.0;
    const horizontalPadding = 8.0;
    const cardRadius = 12.0;

    return Padding(
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
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(cardRadius),
              bottomRight: Radius.circular(cardRadius),
            ),
            color: theme.getScheduleSurfaceColor(
              widget.subject.dateTimeRange,
              isEven: widget.even,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(cardRadius),
                      bottomLeft: Radius.circular(cardRadius),
                    ),
                  ),
                ),
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
                          style: theme.textTheme.titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                          overflow: _expanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                        _textWithIcon(
                          context,
                          Icons.location_on,
                          '${widget.subject.address.auditorium}/${widget.subject.address.building}',
                        ),
                        if (_expanded)
                          _textWithIcon(
                            context,
                            Icons.person,
                            widget.subject.lecturer,
                          ),
                        if (_expanded)
                          _textWithIcon(
                            context,
                            Icons.school,
                            "Поток: ${widget.subject.groups.join("|")}",
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
                        timeFormatter
                            .format(widget.subject.dateTimeRange.start),
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timeFormatter.format(widget.subject.dateTimeRange.end),
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extraColors.ligtherTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textWithIcon(BuildContext context, IconData icon, String text) {
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
            style: theme.textTheme.labelLarge!
                .copyWith(color: extraColors.ligtherTextColor),
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            softWrap: _expanded,
          ),
        ),
      ],
    );
  }
}
