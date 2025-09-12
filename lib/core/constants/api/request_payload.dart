// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

class RequestPayload {
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
