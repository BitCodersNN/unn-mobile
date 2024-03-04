import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

class ScheduleItemNormal extends StatelessWidget {
  final Subject subject;
  final bool even;
  const ScheduleItemNormal({
    super.key,
    required this.subject,
    this.even = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat timeFormatter = DateFormat('HH:mm');
    const ligtherTextColor = Color(0xFF717A84);
    const verticalPadding = 4.0;
    const horizontalPadding = 8.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
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
              Container(
                width: 6,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(3)),
                  color: getColorOfSubjectType(theme, subject.subjectTypeEnum),
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
                        subject.name,
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: ligtherTextColor,
                            size: 16,
                          ),
                          Expanded(
                            child: Text(
                              '${subject.address.auditorium}/${subject.address.building}',
                              style: theme.textTheme.labelLarge!
                                  .copyWith(color: ligtherTextColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        subject.subjectType,
                        style: theme.textTheme.labelLarge!.copyWith(
                            color: getColorOfSubjectType(
                                theme, subject.subjectTypeEnum),
                            fontStyle: FontStyle.italic,
                            overflow: TextOverflow.ellipsis),
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
                      timeFormatter.format(subject.dateTimeRange.start),
                      style: theme.textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Text(
                      timeFormatter.format(subject.dateTimeRange.end),
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ligtherTextColor,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color getSurfaceColor(ThemeData theme) {
    final extraColors = theme.extension<UnnMobileColors>()!;
    if (DateTime.now().isAfter(subject.dateTimeRange.start
            .subtract(const Duration(minutes: 10))) &&
        DateTime.now().isBefore(subject.dateTimeRange.end)) {
      return extraColors.scheduleSubjectHighlight!;
    }

    if (even) {
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
