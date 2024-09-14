import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/widgets/dialogs/changelog_dialog.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_drawer.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_navigation_bar.dart';

class MainPage extends StatefulWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final drawerIdOffset = 10;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await Injector.appInstance
          .get<AppOpenTracker>()
          .isFirstTimeOpenOnVersion()) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => const ChangelogDialog(),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<MainPageViewModel>(
      builder: (context, model, _) {
        return Scaffold(
          drawerEdgeDragWidth: MediaQuery.of(context).size.width,
          extendBody: false,
          drawer: MainPageDrawer(),
          body: widget.child,
          bottomNavigationBar: MainPageNavigationBar(
            onDestinationSelected: (value) {
              GoRouter.of(context)
                  .go(MainPageRouting.navbarRoutes[value].pageRoute);
            },
          ),
        );
      },
      onModelReady: (model) => model.init(),
    );
  }
}
