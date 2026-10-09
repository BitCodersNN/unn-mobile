// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grades_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_book_content.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';
import 'package:unn_mobile/ui/widgets/empty_state_widget.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay_displayer.dart';

class GradesScreenView extends StatelessWidget {
  final int? bottomRouteIndex;

  const GradesScreenView({super.key, this.bottomRouteIndex});

  Future<void> _refresh(GradesScreenViewModel model) {
    triggerHaptic(HapticIntensity.light);
    return model.refresh();
  }

  @override
  Widget build(BuildContext context) => OfflineOverlayDisplayer(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          appBar: AppBar(
            leading: getSubpageLeading(bottomRouteIndex),
            title: const Text('Зачётная книжка'),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            scrolledUnderElevation: 0,
          ),
          body: SafeArea(
            top: false,
            child: BaseView<GradesScreenViewModel>(
              onModelReady: (model) => unawaited(model.refresh()),
              builder: (context, model, _) => Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: _buildContent(model),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildContent(GradesScreenViewModel model) {
    if (model.isBusy && !model.hasGradeBook) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (model.hasError) {
      return _emptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Не удалось загрузить оценки',
        caption: 'Попробуйте обновить зачётную книжку',
        onRefresh: () => _refresh(model),
      );
    }
    if (model.semesters.isEmpty) {
      return _emptyState(
        icon: Icons.menu_book_outlined,
        title: model.hasGradeBook
            ? 'Пока нет оценок'
            : 'Нет загруженной зачётной книжки',
        caption: model.hasGradeBook
            ? 'Оценки появятся после публикации на Портале'
            : 'Подключитесь к сети и обновите данные',
        onRefresh: () => _refresh(model),
      );
    }
    return GradeBookContent(
      model: model,
      onRefresh: () => _refresh(model),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String caption,
    required Future<void> Function() onRefresh,
  }) =>
      LayoutBuilder(
        builder: (context, constraints) => RefreshIndicator.adaptive(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EmptyStateWidget(icon: icon, title: title, caption: caption),
                  TextButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Обновить'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
}
