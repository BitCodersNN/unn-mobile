// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/certificates_online/certificate_item_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/certificates_online/certificates_view_model.dart';
import 'package:unn_mobile/ui/functions.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';
import 'package:unn_mobile/ui/widgets/wide_button.dart';

class OnlineCertificatesScreenView extends StatefulWidget {
  final int? bottomRouteIndex;

  const OnlineCertificatesScreenView({super.key, this.bottomRouteIndex});

  @override
  State<OnlineCertificatesScreenView> createState() =>
      _OnlineCertificatesScreenViewState();
}

class _OnlineCertificatesScreenViewState
    extends State<OnlineCertificatesScreenView> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: getSubpageLeading(widget.bottomRouteIndex),
          title: const Text('Справки онлайн'),
        ),
        body: BaseView<CertificatesViewModel>(
          builder: (context, model, _) {
            if (model.isBusy) {
              return const Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) => RefreshIndicator(
                onRefresh: model.reload,
                child: SingleChildScrollView(
                  // padding: const EdgeInsets.all(16.0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (model.hasError)
                            Center(
                              child: Column(
                                children: [
                                  const Text('Не удалось загрузить...'),
                                  TextButton(
                                    onPressed: () {
                                      model.init();
                                    },
                                    child: const Text('Попробовать снова'),
                                  ),
                                ],
                              ),
                            )
                          else if (model.certificates.isEmpty)
                            const Text('Нет доступных справок')
                          else
                            for (final cert in model.certificates) ...[
                              _buildCertificateCard(cert),
                              const SizedBox(height: 16.0),
                            ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          onModelReady: (p0) => p0.init(),
        ),
      );

  Widget _buildCertificateCard(CertificateItemViewModel viewModel) =>
      BaseView<CertificateItemViewModel>(
        builder: (context, model, _) {
          final theme = Theme.of(context);
          return Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  offset: Offset.zero,
                  blurRadius: 16.0,
                  color: Color(0x20527DAF),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0,
                    left: 16.0,
                    right: 16.0,
                    bottom: model.isViewExpanded ? 0.0 : 15.0,
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Text(
                          model.name,
                          style: const TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (model.isBusy)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                    trailing: Icon(
                      model.isViewExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onTap: () {
                      model.isViewExpanded = !model.isViewExpanded;
                    },
                  ),
                ),
                if (model.isViewExpanded)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.description,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                        if (model.isPractice) ...[
                          _extraField('Тип практики: ', model.practiceType),
                          _extraField(
                            'Название практики: ',
                            model.practiceName,
                          ),
                          _extraField('Даты проведения: ', model.practiceDates),
                        ],
                        const SizedBox(height: 35.0),
                        WideButton(
                          onPressed: model.isBusy
                              ? null
                              : () async {
                                  if (model.downloadAvailable) {
                                    await model.download();
                                  } else {
                                    await model.askForPath();
                                  }
                                },
                          child: Text(
                            model.downloadAvailable ? 'Загрузить' : 'Получить',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (model.downloadAvailable) ...[
                          const SizedBox(height: 16.0),
                          WideButton(
                            onPressed: model.isBusy
                                ? null
                                : () async {
                                    await model.downloadSig();
                                  },
                            child: Text(
                              'Загрузить ЭЦП',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
        model: viewModel,
        onModelReady: (model) {
          model
            ..onSigDownloaded = (file) async {
              await viewFileAndShowMessage(
                context,
                file,
                'Подпись загружена успешно',
              );
            }
            ..onCertificateDownloaded = (file) async {
              await viewFileAndShowMessage(
                context,
                file,
                'Файл загружен успешно',
              );
            };
        },
      );

  Padding _extraField(String title, String? text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 15,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
