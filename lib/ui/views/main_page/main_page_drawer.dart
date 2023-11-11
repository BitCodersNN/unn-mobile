import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';

class MainPageDrawer extends StatelessWidget {
  MainPageDrawer({
    super.key,
    this.onDestinationSelected,
  });
  final List<IconData> drawerIcons = [
    Icons.chat,
    Icons.document_scanner,
    Icons.people,
    Icons.calendar_month,
    Icons.account_tree,
    Icons.shelves,
    Icons.credit_card,
  ];
  final void Function(int)? onDestinationSelected;
  final List<Widget> children = [];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<MainPageViewModel>(
      builder: (context, model, child) {
        if (children.isEmpty) {
          children.addAll(_generateChildren(model, context));
        }
        return NavigationDrawer(
          selectedIndex: model.selectedDrawerItem,
          onDestinationSelected: onDestinationSelected,
          indicatorColor: model.isDrawerItemSelected
              ? theme.navigationDrawerTheme.indicatorColor
              : const Color(0x00000000),
          children: children,
        );
      },
    );
  }

  List<Widget> _generateChildren(
      MainPageViewModel value, BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> drawerChildren = [
      _getDrawerHeader(theme, value),
      for (int i = 0; i < value.drawerScreenNames.length; i++)
        NavigationDrawerDestination(
          icon: Icon(drawerIcons[i]),
          label: Text(value.drawerScreenNames[i]),
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
                                color: theme.colorScheme.onBackground),
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
                      value.userNameAndSurname,
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
    );
  }
}
