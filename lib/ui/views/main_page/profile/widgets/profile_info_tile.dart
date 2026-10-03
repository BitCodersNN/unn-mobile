// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';

class ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const ProfileInfoTile({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      leading: icon == null ? null : Icon(icon),
      title: Text(label, style: theme.textTheme.bodySmall),
      subtitle: Text(value),
    );
  }
}
