// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/about_info_card.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/contact_info_card.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/employment_info_card.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/general_info_card.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/profile_page_header.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/study_info_card.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

/// Экран профиля пользователя.
///
/// Если [userId] не передан явно, id пользователя берётся
/// из route-параметра `:userId`.
class ProfilePage extends StatefulWidget {
  final int? userId;
  final bool loadFromPost;
  final bool isMe;

  const ProfilePage({
    super.key,
    this.userId,
    this.isMe = false,
    this.loadFromPost = false,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileViewModel _model;

  @override
  void initState() {
    super.initState();
    _model = widget.isMe
        ? ProfileViewModel.currentUser()
        : ProfileViewModel.cached(_getUserId() ?? 0);
  }

  int? _getUserId() =>
      widget.userId ??
      int.tryParse(GoRouterState.of(context).pathParameters['userId'] ?? '');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
          forceMaterialTransparency: true,
        ),
        body: BaseView<ProfileViewModel>(
          model: _model,
          builder: (context, model, _) {
            if (model.hasError) {
              return _ProfileLoadError(
                onRetry: () => widget.isMe
                    ? model.init(force: true, loadCurrentUser: true)
                    : model.init(
                        force: true,
                        retryAttempt: 0,
                        userId: _getUserId(),
                      ),
              );
            }
            final data = model.userData;
            return Shimmer(
              child: RefreshIndicator(
                onRefresh: () async => await model.init(
                  force: true,
                  loadCurrentUser: widget.isMe,
                  userId: _getUserId(),
                  loadFromPost: widget.loadFromPost,
                ),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      child: ShimmerLoading(
                        isLoading: model.isLoading,
                        child: ProfilePageHeader(model: model),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!model.isLoading && data != null) ...[
                      GeneralInfoCard(data: data, isMe: model.isMe),
                      if (model.studentData != null)
                        StudyInfoCard(data: model.studentData!),
                      if (model.employeeData != null)
                        EmploymentInfoCard(data: model.employeeData!),
                      ContactInfoCard(data: data),
                      AboutInfoCard(data: data),
                    ],
                  ],
                ),
              ),
            );
          },
          onModelReady: (model) {
            if (!widget.isMe) {
              model.init(
                userId: _getUserId(),
                loadFromPost: widget.loadFromPost,
                force: true,
              );
            }
          },
        ),
      );
}

class _ProfileLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProfileLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 56,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Не удалось загрузить профиль',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
