// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

class CachedGitResource<T> {
  final T data;
  final String? sha;
  final bool isLegacy;

  const CachedGitResource({
    required this.data,
    this.sha,
    this.isLegacy = false,
  });
}
