// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class SettingsMinutesSlider extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChangeEnd;

  const SettingsMinutesSlider({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChangeEnd,
    this.subtitle,
    this.min = 0,
    this.max = 60,
    super.key,
  });

  @override
  State<SettingsMinutesSlider> createState() => _SettingsMinutesSliderState();
}

class _SettingsMinutesSliderState extends State<SettingsMinutesSlider> {
  late int _minutes = widget.value;

  @override
  void didUpdateWidget(covariant SettingsMinutesSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _minutes = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.title, style: theme.textTheme.bodyLarge),
              ),
              const SizedBox(width: 12),
              Text(
                '$_minutes мин',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          Slider(
            padding: const EdgeInsets.symmetric(vertical: 12),
            value: _minutes.toDouble(),
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            divisions: widget.max - widget.min,
            label: '$_minutes мин',
            semanticFormatterCallback: (value) => '${value.round()} мин',
            onChanged: (value) => setState(() => _minutes = value.round()),
            onChangeEnd: (value) => widget.onChangeEnd(value.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.min} мин', style: theme.textTheme.labelSmall),
              Text('${widget.max} мин', style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
