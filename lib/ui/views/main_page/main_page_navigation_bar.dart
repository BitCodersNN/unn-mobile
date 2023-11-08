import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';

class MainPageNavigationBar extends StatelessWidget {
  MainPageNavigationBar({super.key});
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
                  sigmaX: 10.0,
                  sigmaY: 10.0,
                ),
                child: Container(
                    width: double.maxFinite,
                    height: 60,
                    color: Colors.transparent),
              ),
            ),
            NavigationBar(
              destinations: _getNavbarDestinations(
                  model, context),
              height: 60,
              backgroundColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              indicatorShape: const Border(),
              animationDuration: const Duration(milliseconds: 0),
              selectedIndex: model.selectedBarItem,
              onDestinationSelected: (value) {
                model.selectedBarItem = value;
                model.isDrawerItemSelected = false;
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _getNavbarDestinations(
      MainPageViewModel model, BuildContext context) {
    List<Widget> destinations = [];
    final theme = Theme.of(context);
    for (int i = 0; i < model.barScreenNames.length; ++i) {
      var isIconSelected =
          !model.isDrawerItemSelected && model.selectedBarItem == i;
      destinations.add(NavigationDestination(
          icon: Icon(
              isIconSelected ? selectedBarIcons[i] : unselectedBarIcons[i],
              color: isIconSelected
                  ? theme.primaryColor
                  : theme.colorScheme.onBackground),
          label: model.barScreenNames[i]));
    }
    return destinations;
  }
}
