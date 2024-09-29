import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

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
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
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
                ..setBackgroundColor(const Color(0xFFEFF1FB)),
            ),
    );
  }
}
