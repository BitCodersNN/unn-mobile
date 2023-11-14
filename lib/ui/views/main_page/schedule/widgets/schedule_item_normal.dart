import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/models/subject.dart';

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          shape: BoxShape.rectangle,
          color: even
              ? theme.colorScheme.surfaceVariant
              : theme.colorScheme.surface,
        ),
        height: 90,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Positioned(
              left: 30,
              top: 10,
              bottom: 10,
              right: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: theme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: ligtherTextColor,
                        size: 16,
                      ),
                      Text(
                        '${subject.address.auditorium}/${subject.address.building}',
                        style: theme.textTheme.labelLarge!
                            .copyWith(color: ligtherTextColor),
                      ),
                    ],
                  ),
                  Text(
                    subject.subjectType,
                    style: theme.textTheme.labelLarge!.copyWith(
                        color: theme.colorScheme.primary,
                        fontStyle: FontStyle.italic),
                  )
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Text(
                timeFormatter.format(subject.dateTimeRange.start),
                style: theme.textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Text(
                timeFormatter.format(subject.dateTimeRange.end),
                style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold, color: ligtherTextColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
