// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/grade_book/grade_book_summary.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grades_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/grades/widgets/grade_book_content.dart';
import 'package:unn_mobile/ui/views/main_page/main_page.dart';
import 'package:unn_mobile/ui/widgets/empty_state_widget.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay_displayer.dart';

class GradesScreenView extends StatefulWidget {
  final int? bottomRouteIndex;

  const GradesScreenView({super.key, this.bottomRouteIndex});

  @override
  State<GradesScreenView> createState() => _GradesScreenViewState();
}

class _GradesScreenViewState extends State<GradesScreenView> {
  late GradesScreenViewModel _model;
  late Future<GradeBookSummary?> _gradeBook;

  Future<GradeBookSummary?> _load() async {
    final book = await _model.getGradeBook();
    return book == null ? null : GradeBookSummary.fromGradeBook(book);
  }

  Future<void> _refresh() async {
    triggerHaptic(HapticIntensity.light);
    final request = _load();
    setState(() {
      _gradeBook = request;
    });
    try {
      await request;
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) => OfflineOverlayDisplayer(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          appBar: AppBar(
            leading: getSubpageLeading(widget.bottomRouteIndex),
            title: const Text('Зачётная книжка'),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            scrolledUnderElevation: 0,
          ),
          body: SafeArea(
            top: false,
            child: BaseView<GradesScreenViewModel>(
              onModelReady: (model) {
                _model = model;
                _gradeBook = _load();
              },
              builder: (context, model, _) => Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: FutureBuilder<GradeBookSummary?>(
                    future: _gradeBook,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                      if (snapshot.hasError) {
                        return _emptyState(
                          icon: Icons.cloud_off_outlined,
                          title: 'Не удалось загрузить оценки',
                          caption: 'Попробуйте обновить зачётную книжку',
                        );
                      }
                      final summary = snapshot.data;
                      if (summary == null || summary.semesters.isEmpty) {
                        return _emptyState(
                          icon: Icons.menu_book_outlined,
                          title: summary == null
                              ? 'Нет загруженной зачётной книжки'
                              : 'Пока нет оценок',
                          caption: summary == null
                              ? 'Подключитесь к сети и обновите данные'
                              : 'Оценки появятся после публикации на Портале',
                        );
                      }
                      return GradeBookContent(
                        summary: summary,
                        onRefresh: _refresh,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String caption,
  }) =>
      LayoutBuilder(
        builder: (context, constraints) => RefreshIndicator.adaptive(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EmptyStateWidget(icon: icon, title: title, caption: caption),
                  TextButton.icon(
                    onPressed: _refresh,
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
