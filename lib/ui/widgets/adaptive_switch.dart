// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';

class AdaptiveSwtich extends StatefulWidget {
  final bool enabled;
  // для хендлеров нужны позиционные аргументы
  // ignore: avoid_positional_boolean_parameters
  final Function(bool) onChanged;
  final Size size;
  final bool startPosition;

  const AdaptiveSwtich({
    required this.startPosition,
    required this.enabled,
    required this.onChanged,
    super.key,
    this.size = const Size(40, 30),
  });

  @override
  State<AdaptiveSwtich> createState() => _AdaptiveSwtichState();
}

class _AdaptiveSwtichState extends State<AdaptiveSwtich> {
  bool? active;

  @override
  Widget build(BuildContext context) {
    active ??= widget.startPosition;
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: FittedBox(
        child: Switch.adaptive(
          value: active!,
          onChanged: widget.enabled
              ? (bool value) {
                  setState(() {
                    active = value;
                  });
                  widget.onChanged(value);
                }
              : null,
        ),
      ),
    );
  }
}
