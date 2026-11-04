// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) => _SettingsTileTheme(
    child: SwitchListTile.adaptive(
      secondary: _SettingsIcon(icon: icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    ),
  );
}

class SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;
  final bool showChevron;

  const SettingsActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.color,
    this.showChevron = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) => _SettingsTileTheme(
    child: ListTile(
      leading: _SettingsIcon(icon: icon, color: color),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      textColor: color,
      trailing: showChevron
          ? Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 22,
            )
          : null,
      onTap: onTap,
    ),
  );
}

class _SettingsTileTheme extends StatelessWidget {
  final Widget child;

  const _SettingsTileTheme({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        switchTheme: theme.switchTheme.copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.pressed)
                ? Colors.transparent
                : null,
          ),
        ),
      ),
      child: ListTileTheme(
        data: ListTileTheme.of(context).copyWith(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          horizontalTitleGap: 12,
          minLeadingWidth: 36,
          titleTextStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          subtitleTextStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const _SettingsIcon({required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? Theme.of(context).colorScheme.primary;
    return ExcludeSemantics(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: foreground, size: 21),
      ),
    );
  }
}
