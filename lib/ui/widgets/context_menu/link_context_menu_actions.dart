// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';

List<ContextMenuAction> createLinkActions({
  required BuildContext context,
  required String url,
  required VoidCallback onOpen,
}) =>
    [
      ContextMenuAction.text(
        label: 'Открыть',
        onTap: onOpen,
        leadingIcon: const Icon(Icons.open_in_new, size: 18),
      ),
      ContextMenuAction.text(
        label: 'Скопировать ссылку',
        onTap: () {
          Clipboard.setData(ClipboardData(text: url));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ссылка скопирована')),
            );
          }
        },
        leadingIcon: const Icon(Icons.link, size: 18),
      ),
    ];
