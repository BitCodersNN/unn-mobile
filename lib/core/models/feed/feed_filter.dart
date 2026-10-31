// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

enum FeedFilter {
  all('Все'),
  pinned('Закреплённые'),
  important('Важные');

  final String caption;

  const FeedFilter(this.caption);
}
