// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/user/user_functions.dart';

class QueryChip extends StatefulWidget {
  final String label;
  final VoidCallback onClear;

  const QueryChip({
    required this.label,
    required this.onClear,
    super.key,
  });

  @override
  State<QueryChip> createState() => _QueryChipState();
}

class _QueryChipState extends State<QueryChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 220),
    vsync: this,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<double> _scale =
      Tween<double>(begin: 0.8, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        alignment: Alignment.centerRight,
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  shortName(widget.label),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: widget.onClear,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
