// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

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
  String htmlContent = '';

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..loadRequest(
        Uri.parse(
          '${ProtocolType.https.name}://${ApiPath.donation}',
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setTextZoom(100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поддержать'),
      ),
      body: WebViewWidget(
        controller: controller..setBackgroundColor(const Color(0xFFF9FAFF)),
      ),
    );
  }
}
