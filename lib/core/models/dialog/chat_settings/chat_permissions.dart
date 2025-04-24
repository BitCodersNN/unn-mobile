// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/enum_from_string.dart';
import 'package:unn_mobile/core/models/dialog/enum/user_role.dart';

class _ChatPermissionsJsonKeys {
  static const canPost = 'can_post';
  static const manageMessages = 'manage_messages';
  static const manageSettings = 'manage_settings';
  static const manageUI = 'manage_ui';
  static const manageUsersAdd = 'manage_users_add';
  static const manageUsersDelete = 'manage_users_delete';
}

class ChatPermissions {
  final UserRole canPost;
  final UserRole manageMessages;
  final UserRole manageSettings;
  final UserRole manageUI;
  final UserRole manageUsersAdd;
  final UserRole manageUsersDelete;

  ChatPermissions({
    this.canPost = UserRole.member,
    this.manageMessages = UserRole.member,
    this.manageSettings = UserRole.owner,
    this.manageUI = UserRole.member,
    this.manageUsersAdd = UserRole.member,
    this.manageUsersDelete = UserRole.manager,
  });

  factory ChatPermissions.fromJson(Map<String, dynamic> json) =>
      ChatPermissions(
        canPost: _parseRole(json[_ChatPermissionsJsonKeys.canPost]),
        manageMessages:
            _parseRole(json[_ChatPermissionsJsonKeys.manageMessages]),
        manageSettings:
            _parseRole(json[_ChatPermissionsJsonKeys.manageSettings]),
        manageUI: _parseRole(json[_ChatPermissionsJsonKeys.manageUI]),
        manageUsersAdd:
            _parseRole(json[_ChatPermissionsJsonKeys.manageUsersAdd]),
        manageUsersDelete:
            _parseRole(json[_ChatPermissionsJsonKeys.manageUsersDelete]),
      );

  Map<String, dynamic> toJson() => {
        _ChatPermissionsJsonKeys.canPost: _enumToString(canPost),
        _ChatPermissionsJsonKeys.manageMessages: _enumToString(manageMessages),
        _ChatPermissionsJsonKeys.manageSettings: _enumToString(manageSettings),
        _ChatPermissionsJsonKeys.manageUI: _enumToString(manageUI),
        _ChatPermissionsJsonKeys.manageUsersAdd: _enumToString(manageUsersAdd),
        _ChatPermissionsJsonKeys.manageUsersDelete:
            _enumToString(manageUsersDelete),
      };

  static UserRole _parseRole(
    String? value, {
    UserRole defaultValue = UserRole.owner,
  }) {
    if (value == null || value.isEmpty) return defaultValue;
    return enumFromString(UserRole.values, value.toLowerCase()) ?? defaultValue;
  }

  static String _enumToString(UserRole role) {
    return role.toString().split('.').last.toLowerCase();
  }
}
