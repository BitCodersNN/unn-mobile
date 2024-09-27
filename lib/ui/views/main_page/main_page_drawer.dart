import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_navigation_bar.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

class MainPageDrawer extends StatelessWidget {
  final MainPageViewModel model;
  MainPageDrawer({
    super.key,
    this.onDestinationSelected,
    required this.model,
  });

  final void Function(int)? onDestinationSelected;
  final List<Widget> children = [];
  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    if (children.isEmpty) {
      children.addAll(_generateChildren(model, context));
    }
    return NavigationDrawer(
      onDestinationSelected: (value) {
        Scaffold.of(context).closeDrawer();
        GoRouter.of(context).go(
          '${MainPageRouting.navbarRoutes[MainPageNavigationBar.getSelectedBarIndex(context)].pageRoute}/'
          '${MainPageRouting.drawerRoutes[value].pageRoute}',
        );
      },
      selectedIndex: null,
      children: children,
    );
  }

  List<Widget> _generateChildren(
    MainPageViewModel vm,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final routes = MainPageRouting.drawerRoutes;
    final CurrentUserSyncStorage storage =
        Injector.appInstance.get<CurrentUserSyncStorage>();
    final List<Widget> drawerChildren = [
      _getDrawerHeader(theme, vm),
      for (final route in routes)
        if (route.userTypes.contains(storage.typeOfUser))
          NavigationDrawerDestination(
            icon: Icon(route.selectedIcon),
            label: Text(route.pageTitle),
            enabled: !route.isDisabled,
          ),
    ];
    return drawerChildren;
  }

  Widget _getDrawerHeader(ThemeData theme, MainPageViewModel value) {
    return Padding(
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
                            style: theme.textTheme.headlineLarge!.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            value.userNameAndSurname
                                .replaceAll(RegExp('[а-яё ]'), ''),
                          )
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
                      value.userNameAndSurname,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      value.userGroup,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFFFFFF),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
