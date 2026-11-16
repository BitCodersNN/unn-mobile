// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_region.dart';
import 'package:unn_mobile/ui/widgets/context_menu/link_context_menu_actions.dart';
import 'package:unn_mobile/ui/widgets/context_menu/link_preview.dart';

class LinkContextMenu extends StatelessWidget {
  final String url;
  final String label;
  final VoidCallback onOpen;
  final VoidCallback? onTap;
  final Widget child;

  const LinkContextMenu({
    required this.url,
    required this.label,
    required this.onOpen,
    required this.child,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ContextMenuRegion(
    onTap: onTap ?? onOpen,
    actionsBuilder: (context) =>
        createLinkActions(context: context, url: url, onOpen: onOpen),
    header: LinkPreview(url: url, label: label),
    child: child,
  );
}
