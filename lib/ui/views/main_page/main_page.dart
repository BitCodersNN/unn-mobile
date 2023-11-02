import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/chat/chat.dart';
import 'package:unn_mobile/ui/views/main_page/employees/employees.dart';
import 'package:unn_mobile/ui/views/main_page/feed/feed.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_drawer.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_navigation_bar.dart';
import 'package:unn_mobile/ui/views/main_page/map/map.dart';
import 'package:unn_mobile/ui/views/main_page/materials/materials.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/schedule.dart';

class MainPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  MainPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseView<MainPageViewModel>(
      builder: (context, model, child) {
        return Scaffold(
          key: scaffoldKey,
          appBar: getCurrentAppBar(model, context),
          drawerEdgeDragWidth: MediaQuery.of(context).size.width,
          extendBody: true,
          body: model.isDrawerItemSelected
              ? switch (model.selectedDrawerItem) {
                  0 => const ChatScreenView(),
                  1 => const EmployeesScreenView(),
                  >= 2 => const Placeholder(),
                  _ => const Text("Такого экрана не существует :(")
                }
              : switch (model.selectedBarItem) {
                  0 => const FeedScreenView(),
                  1 => const ScheduleScreenView(),
                  2 => const MapScreenView(),
                  3 => const MaterialsScreenView(),
                  _ => const Text("Такого экрана не существует :(")
                },
          drawer: MainPageDrawer(onDestinationSelected: (value) {
            model.selectedDrawerItem = value;
            Future.delayed(const Duration(milliseconds: 100),
                () => model.isDrawerItemSelected = true);
            scaffoldKey.currentState!.closeDrawer();
          }),
          bottomNavigationBar: MainPageNavigationBar(),
        );
      },
    );
  }

  AppBar getCurrentAppBar(MainPageViewModel value, BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(value.selectedScreenName),
      backgroundColor: theme.appBarTheme.backgroundColor,
      actions: [
        IconButton(onPressed: (){}, icon: const Icon(Icons.notifications)),
        IconButton(onPressed: (){}, icon: const Icon(Icons.search)),
      ],
    );
  }
}
