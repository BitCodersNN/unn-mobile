import 'package:flutter/material.dart';

class TabBarItemContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final TextStyle? labelStyle;

  const TabBarItemContent({
    required this.icon,
    required this.label,
    this.color,
    this.labelStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          SizedBox(
            height: 14,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, maxLines: 1, style: labelStyle),
              ),
            ),
          ),
        ],
      );
}
