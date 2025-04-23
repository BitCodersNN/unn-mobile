// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

const Map<String, Map<String, Object>> certificateTypesInfo = {
  'spravka': {
    'name': 'Справка об обучении',
    'sendtype': 1,
    'description':
        'Справка об обучении по месту требования, подписанная электронной цифровой подписью',
  },
  'dormitory': {
    'name': 'Справка в общежитие',
    'sendtype': 3,
    'description':
        'Справка для заселения в общежитие, подписанная электронной цифровой подписью',
  },
  'practices': {
    'sendtype': 2,
    'description':
        'Предписание на практику, подписанное электронной цифровой подписью',
  },
};
