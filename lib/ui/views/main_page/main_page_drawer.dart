import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/profile_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_navigation_bar.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

class MainPageDrawer extends StatefulWidget {
  final MainPageViewModel model;
  const MainPageDrawer({
    super.key,
    this.onDestinationSelected,
    required this.model,
  });

  final void Function(int)? onDestinationSelected;

  @override
  State<MainPageDrawer> createState() => _MainPageDrawerState();
}

class _MainPageDrawerState extends State<MainPageDrawer> {
  final List<Widget> children = [];
  late final List<MainPageRouteData> routes;

  @override
  void initState() {
    super.initState();
    final CurrentUserSyncStorage storage =
        Injector.appInstance.get<CurrentUserSyncStorage>();

    routes = MainPageRouting.drawerRoutes
        .where(
          (route) => route.userTypes.contains(storage.typeOfUser),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    if (children.isEmpty) {
      children.addAll(_generateChildren(widget.model, context));
    }
    return NavigationDrawer(
      onDestinationSelected: (value) {
        Scaffold.of(context).closeDrawer();
        final selectedBarIndex =
            MainPageNavigationBar.getSelectedBarIndex(context);
        final currentPageRoute =
            MainPageRouting.navbarRoutes[selectedBarIndex].pageRoute;
        final destinationSubroute = routes[value].pageRoute;
        GoRouter.of(context).go('$currentPageRoute/$destinationSubroute');
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

    final List<Widget> drawerChildren = [
      _getDrawerHeader(theme, vm.profileViewModel),
      for (final route in routes)
        NavigationDrawerDestination(
          icon: Icon(route.selectedIcon),
          label: Text(route.pageTitle),
          enabled: !route.isDisabled,
        ),
    ];
    return drawerChildren;
  }

  Widget _getDrawerHeader(ThemeData theme, ProfileViewModel value) {
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
                    backgroundImage: value.hasAvatar
                        ? CachedNetworkImageProvider(value.avatarUrl!)
                        : null,
                    child: !value.hasAvatar
                        ? Text(
                            style: theme.textTheme.headlineLarge!.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            value.initials,
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        value.fullname,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                        textWidthBasis: TextWidthBasis.parent,
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
                        value.description,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
