// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class DonationsScreenView extends StatefulWidget {
  final int? bottomRouteIndex;

  const DonationsScreenView({super.key, this.bottomRouteIndex});

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

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setTextZoom(100);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: getSubpageLeading(widget.bottomRouteIndex),
          title: const Text('Поддержать'),
        ),
        body: WebViewWidget(
          controller: controller..setBackgroundColor(const Color(0xFFF9FAFF)),
        ),
      );
}
