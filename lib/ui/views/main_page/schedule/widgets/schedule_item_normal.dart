import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleItemNormal extends StatefulWidget {
  final Subject subject;
  final bool even;
  const ScheduleItemNormal({
    super.key,
    required this.subject,
    this.even = false,
  });

  @override
  State<ScheduleItemNormal> createState() => _ScheduleItemNormalState();
}

class _ScheduleItemNormalState extends State<ScheduleItemNormal>
    with TickerProviderStateMixin {
  bool _expanded = false;
  final vutsScheduleUri = "http://www.ivo.unn.ru/raspisanie-vuts/";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extraColors = theme.extension<UnnMobileColors>()!;
    final DateFormat timeFormatter = DateFormat('HH:mm');
    const verticalPadding = 4.0;
    const horizontalPadding = 8.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: GestureDetector(
        onTap: () async {
          if (widget.subject.name == "Военная подготовка") {
            final Uri url = Uri.parse(vutsScheduleUri);
            if (!await launchUrl(url)) {
              throw Exception("Could not launch $url");
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
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            shape: BoxShape.rectangle,
            color: getSurfaceColor(theme),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 6,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    color: getColorOfSubjectType(
                      theme,
                      widget.subject.subjectTypeEnum,
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
                          "${widget.subject.address.auditorium}/${widget.subject.address.building}",
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
                            color: getColorOfSubjectType(
                              theme,
                              widget.subject.subjectTypeEnum,
                            ),
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
                    children: [
                      Text(
                        timeFormatter
                            .format(widget.subject.dateTimeRange.start),
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Container(),
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
                )
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

  Color getSurfaceColor(ThemeData theme) {
    final extraColors = theme.extension<UnnMobileColors>()!;
    if (DateTime.now().isAfter(widget.subject.dateTimeRange.start
            .subtract(const Duration(minutes: 10))) &&
        DateTime.now().isBefore(widget.subject.dateTimeRange.end)) {
      return extraColors.scheduleSubjectHighlight!;
    }

    if (widget.even) {
      return theme.colorScheme.surfaceVariant;
    } else {
      return theme.colorScheme.surface;
    }
  }

  Color getColorOfSubjectType(ThemeData theme, SubjectType subjectType) {
    final extraColors = theme.extension<UnnMobileColors>()!;
    return extraColors.subjectTypeHighlight![subjectType] ?? theme.primaryColor;
  }
}
