// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

class RequestPayloads {
  /// Константа, описывающая структуру запроса для поиска и управления диалогами.
  ///
  /// Используется в [DialogSearchServiceImpl] для формирования payload при вызовах API,
  /// связанных с загрузкой, поиском и сохранением диалогов. Содержит метаданные и настройки
  /// для динамической загрузки и поиска диалогов, включая фильтрацию по типам сущностей.
  static const Map dialog = {
    'id': 'im-chat-search',
    'context': 'IM_CHAT_SEARCH',
    'entities': [
      {
        'id': 'im-recent-v2',
        'dynamicLoad': true,
        'dynamicSearch': true,
        'options': {
          'withChatByUsers': false,
          'exclude': [],
        },
      }
    ],
    'clearUnavailableItems': false,
    'presentedItems': [],
  };
}
