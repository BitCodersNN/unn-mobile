import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/ui/router.dart';

class ExitingPage extends StatefulWidget {
  const ExitingPage({super.key});

  @override
  State<ExitingPage> createState() => _ExitingPageState();
}

class _ExitingPageState extends State<ExitingPage> {
  Future<void> exit() async {
    await Injector.appInstance.get<StorageService>().clear();
    await DefaultCacheManager().emptyCache();
  }

  @override
  void initState() {
    super.initState();
    exit().then((value) {
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil(Routes.loadingPage, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Text("Выход..."),
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
