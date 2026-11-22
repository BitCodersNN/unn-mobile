// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/giveaway_promo/giveaway_promo_manager.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_catalog.dart';
import 'package:unn_mobile/core/viewmodels/main_page/giveaway_promo/giveaway_promo_view_model.dart';
import 'package:unn_mobile/ui/giveaway_promo/f1_car_painter.dart';
import 'package:unn_mobile/ui/giveaway_promo/giveaway_promo_launcher.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/feed_image_carousel.dart';

const String defaultGiveawayPromoUrl = 'https://t.me/unn_mobile';
const String defaultGiveawayPromoTitle = 'Розыгрыш призов в Telegram!';
const String defaultGiveawayPromoBody =
    'Подписывайся на наш Telegram-канал, следи за новостями UNN Mobile '
    'и участвуй в розыгрыше фирменных призов.';

Future<void> showResolvedGiveawayPromoDialog(
  BuildContext context, {
  required ResolvedAnnouncement resolved,
  required GiveawayPromoManager promoManager,
  Future<bool> Function(String url)? onOpenUrl,
}) {
  final item = resolved.item;
  return showGiveawayPromoDialog(
    context,
    category: item.category,
    animation: item.animation,
    badge: item.badge,
    title: item.title,
    body: item.text,
    actionLabel: item.action?.label,
    telegramUrl: resolved.effectiveActionUrl,
    images: [for (final file in resolved.imageFiles) FileImage(file)],
    onShown: () => unawaited(promoManager.markShown(item.id)),
    onTelegramTap: () => promoManager.markActionClicked(item.id),
    onDismissed: () => promoManager.markDismissed(item.id),
    onOpenUrl: onOpenUrl,
  );
}

Future<void> showGiveawayPromoDialog(
  BuildContext context, {
  AnnouncementCategory category = AnnouncementCategory.giveaway,
  AnnouncementAnimation animation = AnnouncementAnimation.f1Tow,
  String? badge = 'РОЗЫГРЫШ',
  String title = defaultGiveawayPromoTitle,
  String body = defaultGiveawayPromoBody,
  String? actionLabel = 'Перейти в Telegram-канал',
  String? telegramUrl = defaultGiveawayPromoUrl,
  String? actionUrl,
  List<ImageProvider> images = const [],
  VoidCallback? onShown,
  FutureOr<void> Function()? onTelegramTap,
  FutureOr<void> Function()? onDismissed,
  Future<bool> Function(String url)? onOpenUrl,
}) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'Закрыть',
  barrierColor: Colors.black54,
  routeSettings: const RouteSettings(name: 'giveaway-promo'),
  transitionDuration: MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : (animation == AnnouncementAnimation.f1Tow
            ? const Duration(milliseconds: 180)
            : const Duration(milliseconds: 300)),
  pageBuilder: (context, _, _) => GiveawayPromoOverlay(
    category: category,
    animation: animation,
    badge: badge,
    title: title,
    body: body,
    actionLabel: actionLabel,
    telegramUrl: telegramUrl,
    actionUrl: actionUrl,
    images: images,
    onShown: onShown,
    onTelegramTap: onTelegramTap,
    onDismissed: onDismissed,
    onOpenUrl: onOpenUrl ?? launchGiveawayPromoUrl,
  ),
  transitionBuilder: (context, animation, _, child) => child,
);

class GiveawayPromoOverlay extends StatefulWidget {
  final AnnouncementCategory category;
  final AnnouncementAnimation animation;
  final String? badge;
  final String title;
  final String body;
  final String? actionLabel;
  final String? telegramUrl;
  final String? actionUrl;
  final List<ImageProvider> images;
  final VoidCallback? onShown;
  final FutureOr<void> Function()? onTelegramTap;
  final FutureOr<void> Function()? onDismissed;
  final Future<bool> Function(String url) onOpenUrl;

  const GiveawayPromoOverlay({
    required this.onOpenUrl,
    this.category = AnnouncementCategory.giveaway,
    this.animation = AnnouncementAnimation.f1Tow,
    this.badge = 'РОЗЫГРЫШ',
    this.title = defaultGiveawayPromoTitle,
    this.body = defaultGiveawayPromoBody,
    this.actionLabel = 'Перейти в Telegram-канал',
    this.telegramUrl = defaultGiveawayPromoUrl,
    this.actionUrl,
    this.images = const [],
    this.onShown,
    this.onTelegramTap,
    this.onDismissed,
    super.key,
  });

  @override
  State<GiveawayPromoOverlay> createState() => _GiveawayPromoOverlayState();
}

class _GiveawayPromoOverlayState extends State<GiveawayPromoOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final GiveawayPromoViewModel _viewModel;
  late final AnimationController _controller;
  bool _disableAnimations = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _viewModel = GiveawayPromoViewModel(
      onOpenUrl: widget.onOpenUrl,
      category: widget.category,
      animation: widget.animation,
      badge: widget.badge,
      title: widget.title,
      body: widget.body,
      actionLabel: widget.actionLabel,
      telegramUrl: widget.telegramUrl,
      actionUrl: widget.actionUrl,
      images: widget.images,
      onShown: widget.onShown,
      onTelegramTap: widget.onTelegramTap,
      onDismissed: widget.onDismissed,
    );
    _controller = AnimationController(
      vsync: this,
      duration: _viewModel.animationDuration,
    )..addListener(_onAnimation);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _viewModel.notifyShown();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (_disableAnimations) {
      _viewModel.markAnimationsDisabled();
      _controller.value = 1;
    } else if (!_started) {
      unawaited(_controller.forward());
    }
    _started = true;
  }

  void _onAnimation() {
    if (_viewModel.consumeWheelspinHapticTick(
      _controller.value,
      isAnimating: _controller.isAnimating,
      disableAnimations: _disableAnimations,
    )) {
      triggerHaptic(HapticIntensity.light);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_viewModel.isClosing && _controller.value < 1) {
        unawaited(_controller.forward());
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ..removeListener(_onAnimation)
      ..dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleActionTap(GiveawayPromoViewModel model) async {
    if (await model.submitAction()) {
      _popIfCurrent();
    }
  }

  void _popIfCurrent() {
    if (mounted &&
        (ModalRoute.of(context)?.isCurrent ?? false) &&
        _viewModel.beginClose()) {
      _controller.stop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => BaseView<GiveawayPromoViewModel>(
    model: _viewModel,
    builder: (context, model, _) => PopScope<void>(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _controller.stop();
          model.handleRoutePopped();
        }
      },
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, outerConstraints) {
            final isCompact =
                outerConstraints.maxWidth < 360 ||
                outerConstraints.maxHeight < 640;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 12 : 16,
                vertical: isCompact ? 4 : 12,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    _buildContent(model, constraints, isCompact: isCompact),
              ),
            );
          },
        ),
      ),
    ),
  );

  Widget _buildContent(
    GiveawayPromoViewModel model,
    BoxConstraints constraints, {
    required bool isCompact,
  }) {
    final colors = Theme.of(context).colorScheme;
    final viewportHeight = constraints.maxHeight;
    final maxCardWidth = math.min(420.0, constraints.maxWidth);
    final cardChild = _GiveawayCard(
      model: model,
      isCompact: isCompact,
      onClose: _popIfCurrent,
      onActionTap: () => _handleActionTap(model),
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: maxCardWidth,
          maxWidth: maxCardWidth,
          maxHeight: viewportHeight,
        ),
        child: model.isF1Tow
            ? _buildF1TowContent(
                model: model,
                cardChild: cardChild,
                colors: colors,
                maxCardWidth: maxCardWidth,
                viewportHeight: viewportHeight,
                isCompact: isCompact,
              )
            : _buildDefaultContent(model, cardChild),
      ),
    );
  }

  Widget _buildDefaultContent(GiveawayPromoViewModel model, Widget cardChild) =>
      AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final frame = model.computeDefaultEntranceFrame(_controller.value);
          return Opacity(
            opacity: frame.opacity,
            child: Transform.translate(
              offset: Offset(0, frame.dy),
              child: Transform.scale(scale: frame.scale, child: child),
            ),
          );
        },
        child: cardChild,
      );

  Widget _buildF1TowContent({
    required GiveawayPromoViewModel model,
    required Widget cardChild,
    required ColorScheme colors,
    required double maxCardWidth,
    required double viewportHeight,
    required bool isCompact,
  }) {
    final carWidth = isCompact ? 72.0 : 80.0;
    final carHeight = carWidth * 2.0;
    final hookInset = carHeight * (6.0 / 200.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final frame = model.computeChoreography(
          t: _controller.value,
          viewportHeight: viewportHeight,
          carHeight: carHeight,
        );
        final cardCenterX = maxCardWidth / 2;
        final carTop = frame.cardDy - frame.cableGap - carHeight;
        final hookStart = Offset(
          cardCenterX + frame.carShakeDx,
          frame.cardDy - frame.cableGap - hookInset,
        );
        final hitchEnd = Offset(cardCenterX, frame.cardDy);

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Transform.translate(offset: Offset(0, frame.cardDy), child: child),
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      key: const ValueKey('giveaway_tow_cable'),
                      painter: F1TowCablePainter(
                        start: hookStart,
                        end: hitchEnd,
                        color: colors.primary,
                        opacity: frame.towOpacity,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: cardCenterX - carWidth / 2 + frame.carShakeDx,
              top: carTop,
              width: carWidth,
              height: carHeight,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      key: const ValueKey('giveaway_f1_car'),
                      size: Size(carWidth, carHeight),
                      painter: F1CarPainter(
                        primaryColor: const Color(0xFFE10600),
                        accentColor: colors.primary,
                        wheelAngle: frame.wheelAngle,
                        speedIntensity: frame.speedIntensity,
                        slipIntensity: frame.slipIntensity,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: cardChild,
    );
  }
}

class _GiveawayCard extends StatelessWidget {
  final GiveawayPromoViewModel model;
  final bool isCompact;
  final VoidCallback onClose;
  final VoidCallback onActionTap;

  const _GiveawayCard({
    required this.model,
    required this.isCompact,
    required this.onClose,
    required this.onActionTap,
  });

  IconData get _categoryIcon => switch (model.category) {
    AnnouncementCategory.giveaway => Icons.emoji_events_rounded,
    AnnouncementCategory.ad => Icons.campaign_rounded,
    AnnouncementCategory.update => Icons.system_update_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final horizontalPadding = isCompact ? 14.0 : 18.0;
    final badgeText = model.trimmedBadge;
    final actionLabelText = model.trimmedActionLabel;

    return Material(
      key: const ValueKey('giveaway_card'),
      color: colors.surfaceContainerLowest,
      elevation: 8,
      shadowColor: colors.shadow.withValues(alpha: isDark ? 0.35 : 0.14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              isCompact ? 8 : 12,
              8,
              isCompact ? 0 : 4,
            ),
            child: Row(
              children: [
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoryIcon,
                          size: 15,
                          color: colors.onPrimaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          badgeText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                IconButton(
                  key: const ValueKey('giveaway_close_button'),
                  tooltip: 'Закрыть',
                  visualDensity: isCompact
                      ? VisualDensity.compact
                      : VisualDensity.standard,
                  iconSize: isCompact ? 20 : 24,
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                2,
                horizontalPadding,
                isCompact ? 10 : 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    model.title,
                    key: const ValueKey('giveaway_title'),
                    style:
                        (isCompact
                                ? theme.textTheme.titleMedium
                                : theme.textTheme.titleLarge)
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: colors.onSurface,
                            ),
                  ),
                  SizedBox(height: isCompact ? 6 : 8),
                  Text(
                    model.body,
                    key: const ValueKey('giveaway_body'),
                    style:
                        (isCompact
                                ? theme.textTheme.bodySmall
                                : theme.textTheme.bodyMedium)
                            ?.copyWith(
                              height: isCompact ? 1.35 : 1.45,
                              color: colors.onSurfaceVariant,
                            ),
                  ),
                  if (model.images.isNotEmpty) ...[
                    SizedBox(height: isCompact ? 8 : 14),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isCompact ? 180 : double.infinity,
                        ),
                        child: FeedImageCarousel.providers(
                          key: const ValueKey('giveaway_images'),
                          images: model.images,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (model.hasAction && actionLabelText != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                isCompact ? 10 : 18,
              ),
              child: FilledButton.icon(
                key: const ValueKey('giveaway_telegram_button'),
                onPressed: model.isSubmitting ? null : onActionTap,
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(isCompact ? 40 : 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(actionLabelText),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
