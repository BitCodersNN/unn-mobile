// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/common/app_dark_theme.dart';
import 'package:unn_mobile/core/models/common/app_light_theme.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/theme/custom_palette_theme_builder.dart';
import 'package:unn_mobile/ui/theme/theme_palette.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

abstract final class AppTheme {
  static final ThemeData greenLight = _build(
    ColorScheme.fromSeed(seedColor: CustomPaletteConfig.defaultLightPrimary),
    UnnMobileColors.light,
    snackBarActionColor: CustomPaletteConfig.defaultLightPrimary,
  );

  static final ThemeData blueLight = _build(
    ColorScheme.fromSeed(seedColor: const Color(0xFF0969DA)).copyWith(
      primary: const Color(0xFF0969DA),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDDF4FF),
      onPrimaryContainer: const Color(0xFF0550AE),
      surface: Colors.white,
      onSurface: const Color(0xFF1F2328),
      onSurfaceVariant: const Color(0xFF59636E),
      surfaceBright: Colors.white,
      surfaceDim: const Color(0xFFD1D9E0),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF6F8FA),
      surfaceContainer: const Color(0xFFF0F3F6),
      surfaceContainerHigh: const Color(0xFFEFF2F5),
      surfaceContainerHighest: const Color(0xFFE8EDF2),
      outline: const Color(0xFF818B98),
      outlineVariant: const Color(0xFFD1D9E0),
    ),
    UnnMobileColors.blueLight,
  );

  static final ThemeData warmLight = _build(
    ColorScheme.fromSeed(seedColor: const Color(0xFFA85D2F)).copyWith(
      primary: const Color(0xFFA85D2F),
      onPrimary: const Color(0xFFFFFBF5),
      primaryContainer: const Color(0xFFF3DFCE),
      onPrimaryContainer: const Color(0xFF5B2E12),
      surface: const Color(0xFFFBF6EE),
      onSurface: const Color(0xFF2C241E),
      onSurfaceVariant: const Color(0xFF6E6054),
      surfaceBright: const Color(0xFFFFFBF5),
      surfaceDim: const Color(0xFFE3D7C7),
      surfaceContainerLowest: const Color(0xFFFFFBF5),
      surfaceContainerLow: const Color(0xFFF4ECE0),
      surfaceContainer: const Color(0xFFEFE5D6),
      surfaceContainerHigh: const Color(0xFFEAE0D0),
      surfaceContainerHighest: const Color(0xFFE3D7C7),
      outline: const Color(0xFF9A8B7D),
      outlineVariant: const Color(0xFFE3D7C7),
    ),
    UnnMobileColors.warmLight,
  );

  static ColorScheme _darkColors(Color seed, {Color? secondary}) =>
      ColorScheme.fromSeed(
        seedColor: seed,
        secondary: secondary,
        brightness: Brightness.dark,
      ).copyWith(
        error: const Color(0xFFF2B8AD),
        onError: const Color(0xFF601410),
        errorContainer: const Color(0xFF6F2923),
        onErrorContainer: const Color(0xFFFFDAD4),
      );

  static final ThemeData darkGreen = _build(
    _darkColors(CustomPaletteConfig.defaultDarkPrimary).copyWith(
      primary: CustomPaletteConfig.defaultDarkPrimary,
      onPrimary: const Color(0xFF06221E),
      primaryContainer: const Color(0xFF244E47),
      onPrimaryContainer: const Color(0xFFC0EEE3),
      surface: const Color(0xFF101D1B),
      onSurface: const Color(0xFFDEEDE8),
      onSurfaceVariant: const Color(0xFFAFC5BE),
      surfaceDim: const Color(0xFF0C1715),
      surfaceBright: const Color(0xFF334A44),
      surfaceContainerLowest: const Color(0xFF0C1715),
      surfaceContainerLow: const Color(0xFF192B28),
      surfaceContainer: const Color(0xFF203530),
      surfaceContainerHigh: const Color(0xFF293F39),
      surfaceContainerHighest: const Color(0xFF334A44),
      outline: const Color(0xFF819B92),
      outlineVariant: const Color(0xFF3A4E48),
    ),
    UnnMobileColors.dark,
  );

  static final ThemeData darkGraphite = _build(
    _darkColors(const Color(0xFFC3B2EF)).copyWith(
      primary: const Color(0xFFC3B2EF),
      onPrimary: const Color(0xFF33244D),
      primaryContainer: const Color(0xFF44365C),
      onPrimaryContainer: const Color(0xFFECE2FF),
      surface: const Color(0xFF15151E),
      onSurface: const Color(0xFFE6E5EF),
      onSurfaceVariant: const Color(0xFFC1BECE),
      surfaceDim: const Color(0xFF101017),
      surfaceBright: const Color(0xFF404052),
      surfaceContainerLowest: const Color(0xFF15151E),
      surfaceContainerLow: const Color(0xFF1D1D28),
      surfaceContainer: const Color(0xFF252532),
      surfaceContainerHigh: const Color(0xFF2D2D3C),
      surfaceContainerHighest: const Color(0xFF363647),
      outline: const Color(0xFF938F9F),
      outlineVariant: const Color(0xFF454352),
    ),
    UnnMobileColors.graphite,
  );

  static final ThemeData warmDark = _build(
    _darkColors(const Color(0xFFD69A6C)).copyWith(
      primary: const Color(0xFFD69A6C),
      onPrimary: const Color(0xFF2D180A),
      primaryContainer: const Color(0xFF4F3624),
      onPrimaryContainer: const Color(0xFFF7DFCA),
      surface: const Color(0xFF1A1512),
      onSurface: const Color(0xFFEFE5DB),
      onSurfaceVariant: const Color(0xFFBFB0A3),
      surfaceDim: const Color(0xFF14100D),
      surfaceBright: const Color(0xFF3D332C),
      surfaceContainerLowest: const Color(0xFF14100D),
      surfaceContainerLow: const Color(0xFF221C18),
      surfaceContainer: const Color(0xFF2A231E),
      surfaceContainerHigh: const Color(0xFF332B25),
      surfaceContainerHighest: const Color(0xFF3D332C),
      outline: const Color(0xFF8F8073),
      outlineVariant: const Color(0xFF423830),
    ),
    UnnMobileColors.warmDark,
  );

  static final List<ThemePalette<AppLightTheme>> lightPalettes =
      List.unmodifiable([
        ThemePalette(
          value: AppLightTheme.green,
          label: 'Бело-зелёная',
          theme: greenLight,
        ),
        ThemePalette(
          value: AppLightTheme.blue,
          label: 'Бело-синяя',
          theme: blueLight,
        ),
        ThemePalette(
          value: AppLightTheme.warm,
          label: 'Кремовая',
          theme: warmLight,
        ),
      ]);

  static final List<ThemePalette<AppDarkTheme>> darkPalettes =
      List.unmodifiable([
        ThemePalette(
          value: AppDarkTheme.green,
          label: 'Тёмно-зелёная',
          theme: darkGreen,
        ),
        ThemePalette(
          value: AppDarkTheme.graphite,
          label: 'Графитовая',
          theme: darkGraphite,
        ),
        ThemePalette(
          value: AppDarkTheme.warm,
          label: 'Кофейная',
          theme: warmDark,
        ),
      ]);

  static final _lightCustomCache = _CustomThemeCache();
  static final _darkCustomCache = _CustomThemeCache();

  static List<ThemePalette<AppLightTheme>> lightPalettesFor(
    CustomPaletteConfig? custom,
  ) => List.unmodifiable([
    ...lightPalettes,
    ThemePalette(
      value: AppLightTheme.custom,
      label: 'Своя',
      theme: _customThemeFor(custom, brightness: Brightness.light),
    ),
  ]);

  static List<ThemePalette<AppDarkTheme>> darkPalettesFor(
    CustomPaletteConfig? custom,
  ) => List.unmodifiable([
    ...darkPalettes,
    ThemePalette(
      value: AppDarkTheme.custom,
      label: 'Своя',
      theme: _customThemeFor(custom, brightness: Brightness.dark),
    ),
  ]);

  static ThemeData lightThemeFor(
    AppLightTheme theme, {
    CustomPaletteConfig? custom,
  }) => switch (theme) {
    AppLightTheme.custom => _customThemeFor(
      custom,
      brightness: Brightness.light,
    ),
    _ => _themeFor(theme, lightPalettes),
  };

  static ThemeData darkThemeFor(
    AppDarkTheme theme, {
    CustomPaletteConfig? custom,
  }) => switch (theme) {
    AppDarkTheme.custom => _customThemeFor(
      custom,
      brightness: Brightness.dark,
    ),
    _ => _themeFor(theme, darkPalettes),
  };

  static ThemeData _customThemeFor(
    CustomPaletteConfig? custom, {
    required Brightness brightness,
  }) => buildCustomTheme(
    custom ??
        (brightness == Brightness.dark
            ? CustomPaletteConfig.defaultDark()
            : CustomPaletteConfig.defaultLight()),
    brightness: brightness,
  );

  static ThemeData buildCustomTheme(
    CustomPaletteConfig config, {
    required Brightness brightness,
  }) {
    final cache = brightness == Brightness.dark
        ? _darkCustomCache
        : _lightCustomCache;
    return cache.getOrBuild(
      config,
      (resolved) => CustomPaletteThemeBuilder.build(
        resolved,
        brightness: brightness,
        darkColorsFactory: _darkColors,
        themeFactory: _build,
      ),
    );
  }

  static CustomPaletteConfig configFromTheme(ThemeData theme) =>
      CustomPaletteThemeBuilder.configFromTheme(theme);

  static Color colorForSlot(ThemeData theme, PaletteColorSlot slot) =>
      CustomPaletteThemeBuilder.colorForSlot(theme, slot);

  static ThemeData _themeFor<T extends Enum>(
    T value,
    List<ThemePalette<T>> palettes,
  ) => palettes.singleWhere((palette) => palette.value == value).theme;

  static ThemeData _build(
    ColorScheme colors,
    UnnMobileColors extraColors, {
    Color? snackBarActionColor,
    Color? cardColor,
  }) {
    final isDark = colors.brightness == Brightness.dark;
    final effectiveCardColor = cardColor ?? colors.surfaceContainerLowest;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      adaptations: const [_AppSwitchThemeAdaptation()],
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled) ||
              !states.contains(WidgetState.selected)) {
            return null;
          }
          return Color.lerp(
            colors.primary,
            colors.surfaceContainerLow,
            isDark ? 0.35 : 0.2,
          );
        }),
      ),
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.surface,
      canvasColor: colors.surface,
      cardColor: effectiveCardColor,
      appBarTheme: AppBarTheme(
        scrolledUnderElevation: 3,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: colors.brightness,
        primaryColor: colors.primary,
        primaryContrastingColor: colors.onPrimary,
        scaffoldBackgroundColor: colors.surface,
        barBackgroundColor: colors.surface,
      ),
      cardTheme: CardThemeData(
        color: effectiveCardColor,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainerLow,
        modalBackgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: colors.onSurfaceVariant,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: colors.surfaceContainerHighest,
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.surfaceContainerHighest,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? colors.surfaceContainerHighest
            : colors.inverseSurface,
        contentTextStyle: TextStyle(
          color: isDark ? colors.onSurface : colors.onInverseSurface,
          fontSize: 16,
        ),
        actionTextColor:
            snackBarActionColor ??
            (isDark ? colors.primary : colors.inversePrimary),
      ),
      extensions: [extraColors],
    );
  }
}

class _CustomThemeCache {
  CustomPaletteConfig? _config;
  ThemeData? _theme;

  ThemeData getOrBuild(
    CustomPaletteConfig config,
    ThemeData Function(CustomPaletteConfig) builder,
  ) {
    if (_config == config && _theme != null) {
      return _theme!;
    }
    _config = config;
    return _theme = builder(config);
  }
}

class _AppSwitchThemeAdaptation extends Adaptation<SwitchThemeData> {
  const _AppSwitchThemeAdaptation();

  @override
  SwitchThemeData adapt(ThemeData theme, SwitchThemeData defaultValue) =>
      defaultValue;
}
