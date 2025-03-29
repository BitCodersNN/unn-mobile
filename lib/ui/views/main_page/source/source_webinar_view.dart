import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/html_utils/html_widget_callbacks.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_webinar_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class SourceWebinarView extends StatelessWidget {
  final SourceWebinarViewModel model;

  const SourceWebinarView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return BaseView<SourceWebinarViewModel>(
      builder: (context, model, _) {
        final theme = Theme.of(context);
        /*return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.title,
                    style: theme.textTheme.titleLarge,
                  ),
                  SelectableText('Комментарий: ${model.comment}'),
                  if (model.urlStream?.isNotEmpty ?? false)
                    HtmlWidget(
                      'Ссылка на трансляцию: <a href="${model.urlStream}">${model.urlStream}</a>',
                      onTapUrl: htmlWidgetOnTapUrl,
                    ),
                  if (model.urlRecord?.isNotEmpty ?? false)
                    HtmlWidget(
                      'Ссылка на запись: <a href="${model.urlRecord}">${model.urlRecord}</a>',
                      onTapUrl: htmlWidgetOnTapUrl,
                    ),
                ],
              ),
            ),
          ],
        );*/
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: GestureDetector(
            onTap: () {
              model.expanded = !model.expanded;
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                ),
                shape: BoxShape.rectangle,
                color: theme.getTimeBasedSurfaceColor(
                  model.dateTimeRange,
                  isEven: true,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 6,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(3.0),
                        ),
                        color: theme.getColorOfSubjectType(SubjectType.lab),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.title,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: model.expanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                            model.expanded
                                ? SelectableText.rich(
                                    TextSpan(
                                      text: model.comment,
                                      // Потому что SelectableText ворует событие тапа
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          model.expanded = !model.expanded;
                                        },
                                    ),
                                  )
                                : Text(
                                    model.comment,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            if (model.expanded) ...[
                              if (model.urlStream?.isNotEmpty ?? false)
                                HtmlWidget(
                                  'Трансляция: <a href="${model.urlStream}">${model.urlStream}</a>',
                                  onTapUrl: htmlWidgetOnTapUrl,
                                ),
                              if (model.urlRecord?.isNotEmpty ?? false)
                                HtmlWidget(
                                  'Запись: <a href="${model.urlRecord}">${model.urlRecord}</a>',
                                  onTapUrl: htmlWidgetOnTapUrl,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            model.dateTimeRange.start.format(DatePattern.hhmm),
                            style: theme.textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          Text(
                            model.dateTimeRange.end.format(DatePattern.hhmm),
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.unnMobileColors!.ligtherTextColor,
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
      },
      model: model,
    );
  }
}
