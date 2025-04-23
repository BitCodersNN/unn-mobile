// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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

  Future<void> loadHtmlFromAssets() async {
    htmlContent = await rootBundle.loadString('assets/html/donation.html');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadHtmlFromAssets();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false);
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
      body: htmlContent.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(
              controller: controller
                ..loadHtmlString(htmlContent)
                ..setBackgroundColor(const Color(0xFFF9FAFF)),
            ),
    );
  }
}
