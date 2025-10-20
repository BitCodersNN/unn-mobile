// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_course_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/source/source_item_view.dart';

class SourceCourseView extends StatelessWidget {
  final SourceCourseViewModel model;
  const SourceCourseView({required this.model, super.key});

  @override
  Widget build(BuildContext context) => BaseView<SourceCourseViewModel>(
        model: model,
        builder: (context, model, _) => ExpansionTile(
          showTrailingIcon: false,
          title: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  offset: Offset.zero,
                  blurRadius: 16.0,
                  color: Color(0x20527DAF),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 15.0,
              ),
              child: Text(
                model.discipline,
                style: const TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          shape: const Border(),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [for (final i in model.items) SourceItemView(model: i)],
        ),
      );
}
