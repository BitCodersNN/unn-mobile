// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

class AnalyticsLabel {
  /// QueryParams для указания analyticsLabel[b24statAction]
  static const String b24statAction = 'analyticsLabel[b24statAction]';

  /// QueryParam для указания ID фильтра
  static const String filterId = 'analyticsLabel[FILTER_ID]';

  /// QueryParam для указания ID сетки/грида
  static const String gridId = 'analyticsLabel[GRID_ID]';

  /// QueryParam для указания пресета фильтра
  static const String presetId = 'analyticsLabel[PRESET_ID]';

  /// QueryParam для флага поиска
  static const String find = 'analyticsLabel[FIND]';

  /// QueryParam для флага отображения строк
  static const String rows = 'analyticsLabel[ROWS]';

  /// Для управления реакцией к посту/комментарию в живой ленте
  static const String addLike = 'addLike';

  /// Для закрепления поста в живой ленте
  static const String pinBlogPost = 'pinLivefeedEntry';

  /// Для открепления поста в живой ленте
  static const String unpinBlogPost = 'unpinLivefeedEntry';

  /// Значение для идентификатора живой ленты
  static const String liveFeed = 'LIVEFEED';

  /// Значение для временного пресета фильтра
  static const String tmpFilter = 'tmp_filter';

  /// Флаг "Да" (включено/активно)
  static const String yes = 'Y';

  /// Флаг "Нет" (выключено/неактивно)
  static const String no = 'N';
}
