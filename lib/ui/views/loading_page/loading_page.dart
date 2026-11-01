// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/core/viewmodels/loading_page/loading_page_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late final Future<void> _loadingPages;
  final Completer<void> _logoFrame = Completer<void>();

  @override
  Widget build(BuildContext context) => BaseView<LoadingPageViewModel>(
    builder: (context, model, child) => FutureBuilder<void>(
      future: _loadingPages,
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final backgroundColor = theme.colorScheme.surfaceContainerLowest;
        final overlay =
            ThemeData.estimateBrightnessForColor(backgroundColor) ==
                Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: backgroundColor,
            statusBarBrightness: overlay.statusBarBrightness,
            statusBarIconBrightness: overlay.statusBarIconBrightness,
            systemStatusBarContrastEnforced: false,
          ),
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(child: _buildContent(context, model)),
          ),
        );
      },
    ),
    onModelReady: (model) {
      _loadingPages = model.initLoadingPages();
      model.decideRoute(context, loadingPageReady: _waitForLogo(model));
    },
  );

  Future<void> _waitForLogo(LoadingPageViewModel model) async {
    await _loadingPages;
    if (model.logoImage != null) {
      await _logoFrame.future;
    }
  }

  @override
  void dispose() {
    if (!_logoFrame.isCompleted) {
      _logoFrame.complete();
    }
    super.dispose();
  }

  Widget _buildContent(BuildContext context, LoadingPageViewModel model) {
    final page = model.loadingPageData ?? model.defaultPageData;
    return LayoutBuilder(
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
                      page?.title ?? '',
                      page?.titleStyle ?? const TextStyle(),
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
                          frameBuilder: (context, child, frame, _) {
                            if (frame != null && !_logoFrame.isCompleted) {
                              _logoFrame.complete();
                            }
                            return child;
                          },
                          errorBuilder: (context, error, stack) {
                            if (!_logoFrame.isCompleted) {
                              _logoFrame.completeError(error, stack);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
                if (page?.description != null &&
                    page?.descriptionStyle != null) ...[
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
                          page!.description!,
                          page.descriptionStyle!,
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
  }

  Text _text(
    String title,
    TextStyle textStyle, {
    TextAlign textAlign = TextAlign.center,
  }) => Text(
    title,
    style: textStyle,
    textAlign: textAlign,
    maxLines: 3,
    overflow: TextOverflow.ellipsis,
  );
}
