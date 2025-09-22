// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';

ImageProvider<Object>? getUserAvatar(UserData? userData) =>
    userData?.photoSrc != null
        ? CachedNetworkImageProvider(userData!.photoSrc!)
        : null;

String generateInitials(List<String> names) {
  final nonEmpty = names.where((n) => n.isNotEmpty);
  if (nonEmpty.isEmpty) {
    return '?';
  }
  if (nonEmpty.length == 1) {
    return nonEmpty.first[0].toUpperCase();
  }
  return '${nonEmpty.first[0]}${nonEmpty.last[0]}'.toUpperCase();
}
