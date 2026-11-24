// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/views/main_page/settings/widgets/palette_preview/slot_highlight.dart';

abstract final class MiniPreviewStyle {
  static const double outerRadius = 22;
  static const double innerClipRadius = 21;
  static const double widgetCardRadius = 18;
  static const double cardRadius = 14;
  static const double compactRadius = 12;
  static const double mediumRadius = 10;
  static const double smallRadius = 8;
  static const double pillRadius = 6;
  static const double textHighlightRadius = 4;
  static const double barRadius = 2;

  static const double cardBorderAlpha = 0.35;
  static const double subtleBorderAlpha = 0.3;
  static const double footerBorderAlpha = 0.4;
  static const double outerBorderAlpha = 0.6;
  static const double dotInactiveAlpha = 0.7;
  static const double dotBorderAlpha = 0.8;

  static const double fontSizeMicro = 8.5;
  static const double fontSizeCaption = 9;
  static const double fontSizeSmall = 9.5;
  static const double fontSizeBody = 10;
  static const double fontSizeSubhead = 10.5;
  static const double fontSizeTitle = 11;
  static const double fontSizeMetric = 12;
  static const double fontSizeAppBar = 13;

  static const Duration animationDuration = Duration(milliseconds: 180);
  static const Duration categorySwitchDuration = Duration(milliseconds: 200);
  static const Duration pageTransitionDuration = Duration(milliseconds: 250);
}

class MiniScreenFrame extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  final Widget? bottomBar;
  final VoidCallback? onBackgroundTap;

  const MiniScreenFrame({
    required this.appBar,
    required this.body,
    this.bottomBar,
    this.onBackgroundTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              appBar,
              Expanded(
                child: onBackgroundTap == null
                    ? body
                    : GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: onBackgroundTap,
                        child: body,
                      ),
              ),
              ?bottomBar,
            ],
          ),
        ),
      ),
    ),
  );
}

class MiniAppBar extends StatelessWidget {
  final String title;

  const MiniAppBar({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appBarBg = theme.appBarTheme.backgroundColor ?? colors.surface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: appBarBg,
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(
              alpha: MiniPreviewStyle.subtleBorderAlpha,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: MiniPreviewStyle.fontSizeAppBar,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniBottomNavBar extends StatelessWidget {
  static const _items = [
    Icons.newspaper_rounded,
    Icons.calendar_today_rounded,
    Icons.school_outlined,
    Icons.settings_outlined,
  ];

  final int activeIndex;
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;

  const MiniBottomNavBar({
    required this.activeIndex,
    required this.selectedSlot,
    required this.onSlotSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: colors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < _items.length; i++)
            Builder(
              builder: (context) {
                final isActive = i == activeIndex;
                final iconWidget = Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  child: Icon(
                    _items[i],
                    size: 15,
                    color: isActive ? colors.primary : colors.onSurfaceVariant,
                  ),
                );
                if (!isActive) {
                  return iconWidget;
                }
                return SlotHighlight(
                  active: selectedSlot == PaletteColorSlot.primary,
                  borderRadius: BorderRadius.circular(
                    MiniPreviewStyle.mediumRadius,
                  ),
                  onTap: () => onSlotSelected(PaletteColorSlot.primary),
                  child: iconWidget,
                );
              },
            ),
        ],
      ),
    );
  }
}

class MiniSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final double borderAlpha;

  const MiniSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.borderRadius = MiniPreviewStyle.cardRadius,
    this.color,
    this.borderAlpha = MiniPreviewStyle.cardBorderAlpha,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: borderAlpha),
        ),
      ),
      child: child,
    );
  }
}

class MiniLessonTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color barColor;
  final String? startTime;
  final String? endTime;
  final Color? backgroundColor;
  final bool showBorder;
  final double borderRadius;
  final double borderAlpha;
  final EdgeInsetsGeometry padding;
  final double barWidth;
  final double? barHeight;
  final double barSpacing;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const MiniLessonTile({
    required this.title,
    required this.subtitle,
    required this.barColor,
    this.startTime,
    this.endTime,
    this.backgroundColor,
    this.showBorder = true,
    this.borderRadius = MiniPreviewStyle.mediumRadius,
    this.borderAlpha = MiniPreviewStyle.cardBorderAlpha,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    this.barWidth = 3,
    this.barHeight = 22,
    this.barSpacing = 8,
    this.titleStyle,
    this.subtitleStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasTrailingTime = startTime != null && endTime != null;
    final stretchHeight = hasTrailingTime || barHeight == null;

    final row = Row(
      crossAxisAlignment: stretchHeight
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.center,
      children: [
        Container(
          width: barWidth,
          height: stretchHeight ? null : barHeight,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(MiniPreviewStyle.barRadius),
          ),
        ),
        SizedBox(width: barSpacing),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    titleStyle ??
                    theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: MiniPreviewStyle.fontSizeSubhead,
                    ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    subtitleStyle ??
                    theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: MiniPreviewStyle.fontSizeCaption,
                    ),
              ),
            ],
          ),
        ),
        if (hasTrailingTime) ...[
          const SizedBox(width: 6),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                startTime!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: MiniPreviewStyle.fontSizeBody,
                ),
              ),
              Text(
                endTime!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: MiniPreviewStyle.fontSizeMicro,
                ),
              ),
            ],
          ),
        ],
      ],
    );

    final content = stretchHeight ? IntrinsicHeight(child: row) : row;

    if (showBorder) {
      return MiniSurfaceCard(
        color: backgroundColor,
        borderRadius: borderRadius,
        borderAlpha: borderAlpha,
        padding: padding,
        child: content,
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: content,
    );
  }
}

class MiniMarkBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double? fontSize;

  const MiniMarkBadge({
    required this.label,
    required this.color,
    this.fontSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(MiniPreviewStyle.pillRadius),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class HighlightedSlotText extends StatelessWidget {
  final String text;
  final PaletteColorSlot slot;
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightedSlotText({
    required this.text,
    required this.slot,
    required this.selectedSlot,
    required this.onSlotSelected,
    this.style,
    this.padding,
    this.enabled = true,
    this.maxLines,
    this.overflow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      style: style,
    );
    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }
    return SlotHighlight(
      active: enabled && selectedSlot == slot,
      borderRadius: BorderRadius.circular(MiniPreviewStyle.textHighlightRadius),
      onTap: () => onSlotSelected(slot),
      child: child,
    );
  }
}

class HighlightedSlotDivider extends StatelessWidget {
  final PaletteColorSlot selectedSlot;
  final ValueChanged<PaletteColorSlot> onSlotSelected;
  final EdgeInsetsGeometry? outerPadding;
  final EdgeInsetsGeometry? innerPadding;
  final double borderRadius;
  final double thickness;

  const HighlightedSlotDivider({
    required this.selectedSlot,
    required this.onSlotSelected,
    this.outerPadding,
    this.innerPadding,
    this.borderRadius = MiniPreviewStyle.textHighlightRadius,
    this.thickness = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final outlineVariant = Theme.of(context).colorScheme.outlineVariant;
    Widget divider = Divider(
      height: 1,
      thickness: thickness,
      color: outlineVariant,
    );
    if (innerPadding != null) {
      divider = Padding(padding: innerPadding!, child: divider);
    }
    final highlighted = SlotHighlight(
      active: selectedSlot == PaletteColorSlot.outlineVariant,
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: () => onSlotSelected(PaletteColorSlot.outlineVariant),
      child: divider,
    );
    if (outerPadding != null) {
      return Padding(padding: outerPadding!, child: highlighted);
    }
    return highlighted;
  }
}

class MiniDayHeader extends StatelessWidget {
  final String dayName;
  final String dateLabel;
  final bool isToday;
  final PaletteColorSlot? selectedSlot;
  final ValueChanged<PaletteColorSlot>? onSlotSelected;
  final double fontSize;

  const MiniDayHeader({
    required this.dayName,
    required this.dateLabel,
    this.isToday = false,
    this.selectedSlot,
    this.onSlotSelected,
    this.fontSize = MiniPreviewStyle.fontSizeBody,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dayStyle = theme.textTheme.labelSmall?.copyWith(
      color: colors.onSurface,
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
    );

    final dayTitle = selectedSlot != null && onSlotSelected != null
        ? HighlightedSlotText(
            text: dayName,
            slot: PaletteColorSlot.onSurface,
            selectedSlot: selectedSlot!,
            onSlotSelected: onSlotSelected!,
            style: dayStyle,
          )
        : Text(dayName, style: dayStyle);

    return _TrailingRule(
      color: theme.dividerColor.withValues(alpha: 0.25),
      spacing: 6,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          dayTitle,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              dateLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.normal,
                fontSize: fontSize,
              ),
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(
                  MiniPreviewStyle.mediumRadius,
                ),
              ),
              child: Text(
                'Сегодня',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: MiniPreviewStyle.fontSizeMicro,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrailingRule extends SingleChildRenderObjectWidget {
  final Color color;
  final double spacing;

  const _TrailingRule({
    required this.color,
    required this.spacing,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTrailingRule(color: color, spacing: spacing);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTrailingRule renderObject,
  ) {
    renderObject
      ..color = color
      ..spacing = spacing;
  }
}

class _RenderTrailingRule extends RenderProxyBox {
  Color _color;
  double _spacing;

  _RenderTrailingRule({required this._color, required this._spacing});

  Color get color => _color;

  set color(Color value) {
    if (_color == value) {
      return;
    }
    _color = value;
    markNeedsPaint();
  }

  double get spacing => _spacing;

  set spacing(double value) {
    if (_spacing == value) {
      return;
    }
    _spacing = value;
    markNeedsPaint();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childSize = child!.getDryLayout(constraints.loosen());
    final width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : childSize.width;
    return constraints.constrain(Size(width, childSize.height));
  }

  @override
  void performLayout() {
    final child = this.child!
      ..layout(constraints.loosen(), parentUsesSize: true);
    final width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : child.size.width;
    size = constraints.constrain(Size(width, child.size.height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final child = this.child!;
    final startX = child.size.width + _spacing;
    if (startX < size.width) {
      final top = offset.dy + (size.height - 1) / 2;
      context.canvas.drawRect(
        Rect.fromLTWH(offset.dx + startX, top, size.width - startX, 1),
        Paint()..color = _color,
      );
    }
  }
}
