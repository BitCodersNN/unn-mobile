// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

class ChangelogRelease {
  final String version;
  final List<String> changes;
  final bool isTesting;

  const ChangelogRelease({
    required this.version,
    required this.changes,
    this.isTesting = false,
  });
}
