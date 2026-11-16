// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/misc/logging/diagnostic_event.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/profile_card.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/profile_info_tile.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:unn_mobile/ui/widgets/context_menu/link_context_menu.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactInfoCard extends StatelessWidget {
  final UserData data;

  const ContactInfoCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final web = data.web?.trim();
    final tiles = <Widget>[
      if (data.phone != null && data.phone!.isNotEmpty)
        _ContactTile(
          icon: Icons.phone_outlined,
          label: 'Телефон',
          value: data.phone!,
          url: 'tel:${data.phone!}',
          actionLabel: 'Позвонить',
        ),
      if (data.email != null && data.email!.isNotEmpty)
        _ContactTile(
          icon: Icons.email_outlined,
          label: 'Email',
          value: data.email!,
          url: 'mailto:${data.email!}',
          actionLabel: 'Написать письмо',
        ),
      if (web != null && web.isNotEmpty)
        _ContactTile(
          icon: Icons.language_outlined,
          label: 'Сайт',
          value: web,
          url: _toWebUrl(web),
          enableLinkMenu: true,
        ),
    ];
    if (tiles.isEmpty) {
      return const SizedBox.shrink();
    }
    return ProfileCard(title: 'Контакты', tiles: tiles);
  }

  String _toWebUrl(String web) => (Uri.tryParse(web)?.hasScheme ?? false)
      ? web
      : '${ProtocolType.https.name}://$web';
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String url;
  final bool enableLinkMenu;
  final String? actionLabel;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.url,
    this.enableLinkMenu = false,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tile = ProfileInfoTile(
      icon: icon,
      label: label,
      value: value,
      onTap: _openUrl,
      enableCopyMenu: !enableLinkMenu,
      menuActions: [
        if (actionLabel != null)
          ContextMenuAction.text(
            label: actionLabel!,
            leadingIcon: Icon(icon, size: 18),
            onTap: _openUrl,
          ),
      ],
    );
    return enableLinkMenu
        ? LinkContextMenu(url: url, label: value, onOpen: _openUrl, child: tile)
        : tile;
  }

  Future<void> _openUrl() async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      Injector.appInstance.get<LoggerService>().log(
        DiagnosticEvent.urlLaunchFailed,
      );
    }
  }
}
