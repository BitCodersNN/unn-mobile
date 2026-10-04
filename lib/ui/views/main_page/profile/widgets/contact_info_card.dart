// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/profile_card.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactInfoCard extends StatelessWidget {
  final UserData data;

  const ContactInfoCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      if (data.phone != null && data.phone!.isNotEmpty)
        _ContactTile(
          icon: Icons.phone_outlined,
          label: 'Телефон',
          value: data.phone!,
          url: 'tel:${data.phone!}',
        ),
      if (data.email != null && data.email!.isNotEmpty)
        _ContactTile(
          icon: Icons.email_outlined,
          label: 'Email',
          value: data.email!,
          url: 'mailto:${data.email!}',
        ),
      if (data.web != null && data.web!.isNotEmpty)
        _ContactTile(
          icon: Icons.language_outlined,
          label: 'Сайт',
          value: data.web!,
          url: _toWebUrl(data.web!),
        ),
    ];
    if (tiles.isEmpty) {
      return const SizedBox.shrink();
    }
    return ProfileCard(title: 'Контакты', tiles: tiles);
  }

  String _toWebUrl(String web) => web.startsWith('http') ? web : 'https://$web';
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String url;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(value),
      subtitle: Text(label, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right),
      onTap: _openUrl,
    );
  }

  Future<void> _openUrl() async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      Injector.appInstance
          .get<LoggerService>()
          .log('Could not launch url $url');
    }
  }
}
