import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/viewmodels/factories/profile_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

String formatFeedPostTime(DateTime date) =>
    DateFormat('d MMMM yyyy, HH:mm', 'ru_RU').format(date);

class FeedAuthorHeader extends StatelessWidget {
  final ProfileViewModel viewModel;
  final String dateTime;
  final bool compact;
  final bool canOpenProfile;
  final bool isLoading;

  const FeedAuthorHeader({
    required this.viewModel,
    required this.dateTime,
    this.compact = false,
    this.canOpenProfile = false,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return BaseView<ProfileViewModel>(
      model: viewModel,
      builder: (context, model, _) {
        final loading = model.isLoading || isLoading;
        return GestureDetector(
          onTap: canOpenProfile && !loading
              ? () => _openProfile(context, model)
              : null,
          child: Row(
            children: [
              ShimmerLoading(
                isLoading: loading,
                child: Container(
                  width: compact ? 36 : 42,
                  height: compact ? 36 : 42,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(compact ? 18 : 14),
                  ),
                  child: model.hasAvatar
                      ? CachedNetworkImage(
                          imageUrl: model.avatarUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _initials(context, model),
                        )
                      : _initials(context, model),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ShimmerLoading(
                  isLoading: loading,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (loading)
                        Container(
                          height: 16,
                          width: 160,
                          color: colors.surfaceContainerHighest,
                        )
                      else
                        Text(
                          model.fullname,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      if (dateTime.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          dateTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _initials(BuildContext context, ProfileViewModel model) => Center(
        child: Text(
          model.initials,
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );

  void _openProfile(BuildContext context, ProfileViewModel model) {
    final id = model.userData?.bitrixId;
    if (id == null) {
      return;
    }
    triggerHaptic(HapticIntensity.light);
    Injector.appInstance.get<ProfileViewModelFactory>().putInCache(id, model);
    final router = GoRouter.of(context);
    router.go(
      '${router.routeInformationProvider.value.uri.path}/${feedUserProfileRoute.pagePath.replaceAll(':userId', id.toString())}',
    );
  }
}
