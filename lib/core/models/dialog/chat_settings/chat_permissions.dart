import 'package:unn_mobile/core/models/dialog/user_role.dart';

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
}
