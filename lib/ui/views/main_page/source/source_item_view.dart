import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mime/mime.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
import 'package:unn_mobile/core/misc/html_widget_callbacks.dart';
import 'package:unn_mobile/core/viewmodels/source_item_view_model.dart';
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
          model.onFileDownloaded = (file) {
            final mimeType = lookupMimeType(file.path);
            if (mimeType != null) {
              viewFile(file.path, mimeType);
            }
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
              const SnackBar(
                content: Text('Файл сохранён'),
              ),
            );
          };
        }
      },
    );
  }
}
