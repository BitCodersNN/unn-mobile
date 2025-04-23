// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

class PaginatedResultJsonKeys {
  static const String hasPrevPage = 'hasPrevPage';
  static const String hasNextPage = 'hasNextPage';
}

class PartialResultJsonKeys {
  static const String hasMore = 'hasMore';
}

class PaginatedResult<T> {
  final List<T> items;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const PaginatedResult({
    required this.items,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });
}

class PartialResult<T> {
  final List<T> items;
  final bool hasMore;

  const PartialResult({
    required this.items,
    required this.hasMore,
  });
}
