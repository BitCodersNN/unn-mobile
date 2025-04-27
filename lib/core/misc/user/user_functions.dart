// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/profile/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';

String getUserInitials(UserData? userData) {
  final String name = userData?.fullname.name ?? '';
  final String surname = userData?.fullname.surname ?? '';
  final String lastname = userData?.fullname.lastname ?? '';

  return generateInitials([name, lastname, surname]);
}

ImageProvider<Object>? getUserAvatar(UserData? userData) {
  ImageProvider<Object>? userAvatar;
  if (userData is StudentData) {
    final StudentData studentProfile = userData;
    userAvatar = studentProfile.fullUrlPhoto == null
        ? null
        : CachedNetworkImageProvider(studentProfile.fullUrlPhoto!);
  } else if (userData is EmployeeData) {
    final EmployeeData employeeProfile = userData;
    userAvatar = employeeProfile.fullUrlPhoto == null
        ? null
        : CachedNetworkImageProvider(employeeProfile.fullUrlPhoto!);
  }
  return userAvatar;
}

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
