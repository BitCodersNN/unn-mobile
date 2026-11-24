// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/donations/donations_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class DonationsScreenView extends StatelessWidget {
  const DonationsScreenView({super.key});

  @override
  Widget build(BuildContext context) => BaseView<DonationsViewModel>(
    onDispose: (model) => model.dispose(),
    builder: (context, model, child) => _DonationsWebViewHost(model: model),
  );
}

class _DonationsWebViewHost extends StatefulWidget {
  final DonationsViewModel model;

  const _DonationsWebViewHost({required this.model});

  @override
  State<_DonationsWebViewHost> createState() => _DonationsWebViewHostState();
}

class _DonationsWebViewHostState extends State<_DonationsWebViewHost> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => widget.model.onPageStarted(),
          onPageFinished: (_) {
            if (!mounted) {
              return;
            }
            widget.model.onPageFinished();
            controller.runJavaScript(widget.model.themeUpdateScript);
          },
        ),
      );

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setTextZoom(100);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scheme = Theme.of(context).colorScheme;
    controller.setBackgroundColor(scheme.surface);
    final action = widget.model.updateTheme(
      brightness: scheme.brightness,
      colors: DonationsThemeColors(
        background: scheme.surface,
        surface: scheme.surfaceContainerLow,
        foreground: scheme.onSurface,
        muted: scheme.onSurfaceVariant,
        primary: scheme.primary,
        outline: scheme.outlineVariant,
      ),
    );
    final initialUri = action.initialUri;
    final script = action.script;
    if (initialUri != null) {
      controller.loadRequest(initialUri);
    } else if (script != null) {
      controller.runJavaScript(script);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Поддержать'),
      forceMaterialTransparency: true,
    ),
    body: WebViewWidget(controller: controller),
  );
}
