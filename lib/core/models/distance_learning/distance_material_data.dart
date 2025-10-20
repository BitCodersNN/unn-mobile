// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';

abstract base class DistanceMaterialData {
  final String comment;
  final DateTime dateTime;

  DistanceMaterialData({
    required this.comment,
    required this.dateTime,
  });

  JsonMap toJson();
}
