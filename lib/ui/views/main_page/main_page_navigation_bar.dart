import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

class MainPageNavigationBar extends StatelessWidget {
  final void Function(int)? onDestinationSelected;

  MainPageNavigationBar({super.key, this.onDestinationSelected});
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

  @override
  Widget build(BuildContext context) {
    return Consumer<MainPageViewModel>(
      builder: (context, model, child) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 6.0,
                  sigmaY: 6.0,
                ),
                child: Container(
                  width: double.maxFinite,
                  height: 60,
                  color: Colors.transparent,
                ),
              ),
            ),
            NavigationBar(
              destinations: _getNavbarDestinations(
                model,
                context,
              ),
              height: 60,
              backgroundColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              indicatorShape: const Border(),
              animationDuration: const Duration(milliseconds: 0),
              selectedIndex: getSelectedBarIndex(context),
              onDestinationSelected: onDestinationSelected,
            ),
          ],
        );
      },
    );
  }

  static int getSelectedBarIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    return MainPageRouting.navbarRoutes
        .indexWhere((route) => location.startsWith(route.pageRoute));
  }

  List<Widget> _getNavbarDestinations(
    MainPageViewModel model,
    BuildContext context,
  ) {
    final routes = MainPageRouting.navbarRoutes;
    final destinations = [
      for (final route in routes)
        NavigationDestination(
          icon: Icon(route.unselectedIcon),
          selectedIcon: Icon(route.selectedIcon),
          label: route.pageTitle,
          enabled: !route.isDisabled,
        ),
    ];
    return destinations;
  }
}
