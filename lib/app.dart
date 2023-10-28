import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/views/auth_page/auth_page.dart';

class UnnMobile extends StatelessWidget {
  const UnnMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthPage(),
    );
  }
}
