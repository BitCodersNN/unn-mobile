// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

abstract base class DistanceMaterialData {
  final String comment;
  final DateTime dateTime;

  DistanceMaterialData({
    required this.comment,
    required this.dateTime,
  });

  Map<String, Object?> toJson();
}
