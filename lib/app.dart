import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/router.dart' as router;
import 'package:unn_mobile/ui/views/loader_page/loader_page.dart';

class UnnMobile extends StatelessWidget {
  const UnnMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoaderPage(),
      onGenerateRoute: router.Router.generateRoute,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xAA1A63B7)),
      ),
    );
  }
}
