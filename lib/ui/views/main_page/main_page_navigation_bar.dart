import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/ui/router.dart';

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
              onDestinationSelected: onDestinationSelected, 
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
