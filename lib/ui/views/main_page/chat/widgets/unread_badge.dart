// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({
    required this.unreadCount,
    super.key,
  });

  final String unreadCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        unreadCount,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
