import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/chat/chat.dart';
import 'package:unn_mobile/ui/views/main_page/employees/employees.dart';
import 'package:unn_mobile/ui/views/main_page/feed/feed.dart';
import 'package:unn_mobile/ui/views/main_page/map/map.dart';
import 'package:unn_mobile/ui/views/main_page/materials/materials.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/schedule.dart';

class MainPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  MainPage({super.key});

  final List<IconData> selectedBarIcons = [
    Icons.star,
    Icons.calendar_month,
    Icons.map,
    Icons.menu_book,
  ];
  final List<IconData> unselectedBarIcons = [
    Icons.star_border,
    Icons.calendar_month_outlined,
    Icons.map_outlined,
    Icons.menu_book_outlined,
  ];

  final List<IconData> drawerIcons = [
    Icons.chat,
    Icons.document_scanner,
    Icons.people,
    Icons.calendar_month,
    Icons.account_tree,
    Icons.shelves,
    Icons.credit_card,
  ];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseView<MainPageViewModel>(
      builder: (context, model, child) {
        List<Widget> drawerChildren = createDrawerChildren(model, context);
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
          drawer: NavigationDrawer(
            selectedIndex: model.selectedDrawerItem,
            onDestinationSelected: (value) {
              model.selectedDrawerItem = value;
              Future.delayed(const Duration(milliseconds: 100),
                  () => model.isDrawerItemSelected = true);
              scaffoldKey.currentState!.closeDrawer();
            },
            indicatorColor: model.isDrawerItemSelected
                ? theme.navigationDrawerTheme.indicatorColor
                : const Color(0x00000000),
            children: drawerChildren,
          ),
          bottomNavigationBar: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 2.0,
                    sigmaY: 2.0,
                  ),
                  child: Container(
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.width * .2,
                      color: Colors.black.withOpacity(0)),
                ),
              ),
              NavigationBar(
                destinations: getNavbarDestinations(
                    model, selectedBarIcons, unselectedBarIcons),
                backgroundColor: Colors.transparent,
                indicatorColor: model.isDrawerItemSelected
                    ? Colors.transparent
                    : Colors.lightBlue,
                selectedIndex: model.selectedBarItem,
                indicatorShape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                onDestinationSelected: (value) {
                  model.selectedBarItem = value;
                  Future.delayed(const Duration(milliseconds: 100),
                      () => model.isDrawerItemSelected = false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> createDrawerChildren(
      MainPageViewModel value, BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> drawerChildren = [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: SizedBox(
          height: 120,
          child: ColoredBox(
            color: theme.colorScheme.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: VerticalDirection.up,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: CircleAvatar(
                      backgroundImage: value.userAvatar,
                      child: value.userAvatar == null
                          ? Text(
                              style: theme.textTheme.headlineLarge!.copyWith(color: theme.colorScheme.onBackground),
                              value.userNameAndSurname
                                  .replaceAll(RegExp('[а-яё ]'), ''))
                          : null,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Имя Фамилия",
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimary,
                          fontFamily: "Inter",
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "3821Б1",
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFFFFFF),
                          fontFamily: "Inter",
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      )
    ];
    for (int i = 0; i < value.drawerScreenNames.length; i++) {
      drawerChildren.add(NavigationDrawerDestination(
        icon: Icon(drawerIcons[i]),
        label: Text(value.drawerScreenNames[i]),
      ));
    }
    return drawerChildren;
  }

  AppBar getCurrentAppBar(MainPageViewModel value, BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(value.selectedScreenName),
      backgroundColor: theme.appBarTheme.backgroundColor,
    );
  }

  List<Widget> getNavbarDestinations(MainPageViewModel model,
      List<IconData> selectedBarIcons, List<IconData> unselectedBarIcons) {
    List<Widget> destinations = [];
    for (int i = 0; i < model.barScreenNames.length; ++i) {
      destinations.add(NavigationDestination(
          icon: Icon(!model.isDrawerItemSelected && model.selectedBarItem == i
              ? selectedBarIcons[i]
              : unselectedBarIcons[i]),
          label: model.barScreenNames[i]));
    }
    return destinations;
  }
}
