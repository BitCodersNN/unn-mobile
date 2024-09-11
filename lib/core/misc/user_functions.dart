import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';

String getUserInitials(UserData? userData) {
  final String name = userData?.fullname.name ?? '';
  final String surname = userData?.fullname.surname ?? '';
  final String lastname = userData?.fullname.lastname ?? '';
  String initials = '';
  if (name != '') {
    initials += name[0];
  }
  if (surname != '') {
    initials += surname[0];
  }
  if (initials.length < 2 && lastname != '') {
    initials += lastname[0];
  }
  if (initials == '') {
    initials = '?';
  }
  return initials;
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
