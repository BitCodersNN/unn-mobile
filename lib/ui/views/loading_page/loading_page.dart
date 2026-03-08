// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/loading_page/loading_page_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) => BaseView<LoadingPageViewModel>(
        builder: (context, model, child) => FutureBuilder<void>(
          future: model.initLoadingPages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(backgroundColor: Colors.white);
            } else {
              return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(child: _buildContent(context, model)),
              );
            }
          },
        ),
        onModelReady: (model) => model.decideRoute(context),
      );

  Widget _buildContent(BuildContext context, LoadingPageViewModel model) =>
      LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 0,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _text(
                        model.loadingPageData?.title ?? '',
                        model.loadingPageData?.titleStyle ?? const TextStyle(),
                      ),
                    ),
                  ),
                  if (model.logoImage != null) ...[
                    const SizedBox(height: 20),
                    Flexible(
                      flex: 1,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.file(
                            model.logoImage!,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (model.loadingPageData?.description != null &&
                      model.loadingPageData?.descriptionStyle != null) ...[
                    const SizedBox(height: 20),
                    Flexible(
                      flex: 0,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.8,
                          ),
                          child: _text(
                            model.loadingPageData!.description!,
                            model.loadingPageData!.descriptionStyle!,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

  Text _text(
    String title,
    TextStyle textStyle, {
    TextAlign textAlign = TextAlign.center,
  }) =>
      Text(
        title,
        style: textStyle,
        textAlign: textAlign,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
}
