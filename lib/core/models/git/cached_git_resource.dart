// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

class CachedGitResource<T> {
  final T data;
  final String? sha;

  const CachedGitResource({required this.data, this.sha});
}
