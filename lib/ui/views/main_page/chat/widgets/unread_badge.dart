import 'package:flutter/material.dart';

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({
    super.key,
    required this.unreadCount,
  });

  final String unreadCount;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          unreadCount,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
