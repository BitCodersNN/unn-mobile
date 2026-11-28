// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/viewmodels/loading_page/loading_page_view_model.dart';
import 'package:unn_mobile/ui/main_page_locations.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late final Future<void> _loadingPages;
  final Completer<void> _logoFrame = Completer<void>();

  Future<void> _navigateWhenReady(LoadingPageViewModel model) async {
    final target = await model.decideRoute(
      loadingPageReady: _waitForLogo(model),
    );
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    final route = switch (target) {
      LoadingRouteTarget.auth => authPageRoute,
      LoadingRouteTarget.main => mainPageRoute,
    };
    GoRouter.of(context).go(route);
  }

  @override
  Widget build(BuildContext context) => BaseView<LoadingPageViewModel>(
    onModelReady: (model) {
      _loadingPages = model.initLoadingPages(
        brightness: Theme.of(context).brightness,
      );
      unawaited(_navigateWhenReady(model));
    },
    onDispose: (model) => model.dispose(),
    builder: (context, model, child) => FutureBuilder<void>(
      future: _loadingPages,
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final backgroundColor = theme.colorScheme.surface;
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
    final page = model.loadingPageData;
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
                    child: _text(context, page.title, page.titleStyle),
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
                if (page.description != null &&
                    page.descriptionStyle != null) ...[
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
                          context,
                          page.description!,
                          page.descriptionStyle!,
                          isDescription: true,
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
    BuildContext context,
    String title,
    TextStyle textStyle, {
    TextAlign textAlign = TextAlign.center,
    bool isDescription = false,
  }) {
    final theme = Theme.of(context);
    final textColor = isDescription
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurface;
    return Text(
      title,
      style: textStyle.copyWith(color: textStyle.color ?? textColor),
      textAlign: textAlign,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
