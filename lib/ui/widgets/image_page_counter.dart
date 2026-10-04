// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

class ImagePageCounter extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const ImagePageCounter({
    required this.currentPage,
    required this.pageCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) => pageCount <= 1
      ? const SizedBox.shrink()
      : IgnorePointer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$currentPage/$pageCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
}
