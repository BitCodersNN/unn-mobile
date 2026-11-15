// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/html_utils/html_widget_callbacks.dart';
import 'package:unn_mobile/ui/widgets/context_menu/link_context_menu.dart';

class LinkAction extends StatelessWidget {
  final String url;
  final String label;
  final Widget child;

  const LinkAction({
    required this.url,
    required this.label,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    label: label,
    child: LinkContextMenu(
      url: url,
      label: label,
      onOpen: () => htmlWidgetOnTapUrl(url),
      child: child,
    ),
  );
}
