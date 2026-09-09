// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

class MainPageDrawer extends StatefulWidget {
  final MainPageViewModel model;
  final void Function(int)? onDestinationSelected;

  const MainPageDrawer({
    required this.model,
    super.key,
    this.onDestinationSelected,
  });

  @override
  State<MainPageDrawer> createState() => _MainPageDrawerState();
}

class _MainPageDrawerState extends State<MainPageDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return OnlineStatusBuilder(
      builder: (context, value) => NavigationDrawer(
        onDestinationSelected: widget.onDestinationSelected,
        selectedIndex: null,
        children: _generateChildren(widget.model, value, context),
      ),
    );
  }

  List<Widget> _generateChildren(
    MainPageViewModel viewModel,
    bool isOnline,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    final List<Widget> drawerChildren = [
      _getDrawerHeader(theme, viewModel),
      for (final route in viewModel.routes)
        if (!route.onlineOnly || isOnline)
          NavigationDrawerDestination(
            icon: Icon(route.selectedIcon),
            label: Text(route.pageTitle),
            enabled: !route.isDisabled,
          ),
    ];
    return drawerChildren;
  }

  Widget _getDrawerHeader(ThemeData theme, MainPageViewModel model) {
    final theme = Theme.of(context);

    return ShimmerLoading(
      isLoading: model.isBusy,
      child: Padding(
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
                    child: model.profileViewModel == null
                        ? const CircleAvatar(child: Text('?'))
                        : CircleAvatar(
                            backgroundImage: model.profileViewModel!.hasAvatar
                                ? CachedNetworkImageProvider(
                                    model.profileViewModel!.avatarUrl!,
                                  )
                                : null,
                            child: !model.profileViewModel!.hasAvatar
                                ? Text(
                                    style:
                                        theme.textTheme.headlineLarge!.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    model.profileViewModel!.initials,
                                  )
                                : null,
                          ),
                  ),
                ),
                Expanded(
                  child: model.profileViewModel == null
                      ? Text(
                          'Ошибка загрузки',
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
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                model.profileViewModel!.fullname,
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
                                model.profileViewModel!.description,
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.surfaceBright,
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
      ),
    );
  }
}
