import 'package:unn_mobile/core/misc/enum_to_string.dart';
import 'package:unn_mobile/core/models/dialog/enum/user_role.dart';

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
        canPost: enumFromString(
          UserRole.values,
          json['can_post'],
        ),
        manageMessages: enumFromString(
          UserRole.values,
          json['manage_messages'],
        ),
        manageSettings: enumFromString(
          UserRole.values,
          json['manage_settings'],
        ),
        manageUI: enumFromString(
          UserRole.values,
          json['manage_ui'],
        ),
        manageUsersAdd: enumFromString(
          UserRole.values,
          json['manage_users_add'],
        ),
        manageUsersDelete: enumFromString(
          UserRole.values,
          json['manage_users_delete'],
        ),
      );
}
