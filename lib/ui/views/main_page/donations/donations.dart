// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class DonationsScreenView extends StatefulWidget {
  const DonationsScreenView({super.key});

  @override
  State<DonationsScreenView> createState() => _DonationsScreenViewState();
}

class _DonationsScreenViewState extends State<DonationsScreenView> {
  late final WebViewController controller;
  Uri? _pageUri;
  bool _pageLoaded = false;
  String _pageTheme = 'light';
  Map<String, String> _pageColors = {};

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _pageLoaded = false,
          onPageFinished: (_) {
            _pageLoaded = true;
            _updatePageTheme();
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
    _pageTheme = scheme.brightness == Brightness.dark ? 'dark' : 'light';
    String hex(Color color) =>
        (color.toARGB32() & 0x00ffffff).toRadixString(16).padLeft(6, '0');
    _pageColors = {
      'background': hex(scheme.surface),
      'surface': hex(scheme.surfaceContainerLow),
      'foreground': hex(scheme.onSurface),
      'muted': hex(scheme.onSurfaceVariant),
      'primary': hex(scheme.primary),
      'outline': hex(scheme.outlineVariant),
    };
    controller.setBackgroundColor(scheme.surface);
    if (_pageUri == null) {
      final baseUri = Uri.parse(
        '${ProtocolType.https.name}://${ApiPath.donation}',
      );
      _pageUri = baseUri.replace(
        queryParameters: {
          ...baseUri.queryParameters,
          'embedded': '1',
          'theme': _pageTheme,
          ..._pageColors,
        },
      );
      controller.loadRequest(_pageUri!);
    } else if (_pageLoaded) {
      _updatePageTheme();
    }
  }

  void _updatePageTheme() {
    controller.runJavaScript(
      'window.setSupportTheme?.(${jsonEncode(_pageTheme)}, '
      '${jsonEncode(_pageColors)});',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поддержать'),
        forceMaterialTransparency: true,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
