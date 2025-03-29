import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:unn_mobile/core/misc/html_utils/html_widget_callbacks.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_item_view_model.dart';
import 'package:unn_mobile/ui/functions.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class SourceItemView extends StatelessWidget {
  final SourceItemViewModel model;
  const SourceItemView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return BaseView<SourceItemViewModel>(
      model: model,
      builder: (context, model, _) {
        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (model.comment.isNotEmpty) Text(model.comment),
                        if (model.isLink)
                          HtmlWidget(
                            '<a href="${model.link}">${model.link}</a>',
                            onTapUrl: htmlWidgetOnTapUrl,
                          )
                        else if (model.isFile)
                          Text('Файл: ${model.fileName}'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: model.isBusy
                          ? const CircularProgressIndicator()
                          : null,
                    ),
                  ),
                  if (model.isFile)
                    ElevatedButton(
                      onPressed: () async {
                        await model.downloadFile();
                      },
                      child: const Text('Скачать'),
                    ),
                ],
              ),
            ),
            const Divider(),
          ],
        );
      },
      onModelReady: (p0) {
        if (model.isFile) {
          model.onFileDownloaded = (file) async {
            await viewFileAndShowMessage(context, file, 'Файл сохранён');
          };
        }
      },
    );
  }
}
