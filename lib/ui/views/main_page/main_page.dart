import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/ui/views/main_page/feed/feed.dart';
import 'package:unn_mobile/ui/views/main_page/grades/grades.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_tab_state.dart';
import 'package:unn_mobile/ui/views/main_page/settings/settings.dart';
import 'package:unn_mobile/ui/widgets/dialogs/changelog_dialog.dart';
import 'package:unn_mobile/ui/widgets/placeholder.dart' as placeholder;
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/about/about.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_drawer.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_navigation_bar.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/schedule.dart';
import 'package:unn_mobile/ui/router.dart' as local_router;

class MainPage extends StatefulWidget {
  final String subroute;

  const MainPage({super.key, required this.subroute});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<int, GlobalKey> tabKeys = {
    1: GlobalKey<State<ScheduleScreenView>>(),
  };

  final List<String> drawerRoutes = [
    'grades',
    'settings',
    'about',
  ];
  final List<String> navbarRoutes = [
    'feed',
    'schedule',
    'placeholder',
    'placeholder',
  ];

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
      builder: (context, model, child) {
        return Scaffold(
          key: scaffoldKey,
          appBar: getCurrentAppBar(model, context),
          drawerEdgeDragWidth: MediaQuery.of(context).size.width,
          extendBody: false,
          body: Navigator(
            key: _navigatorKey,
            initialRoute: widget.subroute,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case 'about':
                  return local_router.Router.createCustomRoute(
                    AboutScreenView(),
                  );
                case 'feed':
                  return local_router.Router.createCustomRoute(
                    const FeedScreenView(),
                  );
                case 'grades':
                  return local_router.Router.createCustomRoute(
                    const GradesScreenView(),
                  );
                case '':
                case 'schedule':
                  tabKeys[1] = GlobalKey<State<ScheduleScreenView>>();
                  return local_router.Router.createCustomRoute(
                    ScheduleScreenView(key: tabKeys[1]),
                  );
                case 'settings':
                  return local_router.Router.createCustomRoute(
                    const SettingsScreenView(),
                  );
                case 'placeholder':
                  return local_router.Router.createCustomRoute(
                    const placeholder.Placeholder(),
                  );
                default:
                  return local_router.Router.createCustomRoute(
                    const Text('Unknown page'),
                  );
              }
            },
          ),
          drawer: MainPageDrawer(
            onDestinationSelected: (value) {
              final bool stateChanged = !model.isDrawerItemSelected ||
                  model.selectedDrawerItem != value;
              model.selectedDrawerItem = value;
              model.isDrawerItemSelected = true;
              scaffoldKey.currentState!.closeDrawer();
              if (stateChanged) {
                _navigatorKey.currentState!.popAndPushNamed(
                  drawerRoutes[value],
                );
              } else {
                if (tabKeys.containsKey(drawerIdOffset + value)) {
                  if (tabKeys[value]!.currentState != null &&
                      tabKeys[value]!.currentState is MainPageTabState) {
                    (tabKeys[value]!.currentState as MainPageTabState)
                        .refreshTab();
                  }
                }
              }
            },
          ),
          bottomNavigationBar: MainPageNavigationBar(
            onDestinationSelected: (value) {
              final bool stateChanged =
                  model.isDrawerItemSelected || model.selectedBarItem != value;
              model.selectedBarItem = value;
              model.isDrawerItemSelected = false;
              if (stateChanged) {
                _navigatorKey.currentState!
                    .popAndPushNamed(navbarRoutes[value]);
              } else {
                if (tabKeys.containsKey(value)) {
                  if (tabKeys[value]!.currentState != null &&
                      tabKeys[value]!.currentState is MainPageTabState) {
                    (tabKeys[value]!.currentState as MainPageTabState)
                        .refreshTab();
                  }
                }
              }
            },
          ),
        );
      },
      onModelReady: (model) => model.init(),
    );
  }

  AppBar getCurrentAppBar(MainPageViewModel model, BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(model.selectedScreenName),
      backgroundColor: theme.appBarTheme.backgroundColor,
      /*actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
      ],*/
    );
  }
}
