import 'package:unn_mobile/core/models/dialog/chat_settings/chat_permissions.dart';
import 'package:unn_mobile/core/models/dialog/chat_settings/chat_restrictions.dart';
import 'package:unn_mobile/core/models/dialog/enum/user_role.dart';

class ChatSetting {
  final List<int> managerList;
  final List<int> muteList;
  final int owner;
  final UserRole role;
  final int userCounter;
  final ChatPermissions permissions;
  final ChatRestrictions restrictions;

  ChatSetting({
    required this.managerList,
    required this.muteList,
    required this.owner,
    required this.role,
    required this.userCounter,
    required this.permissions,
    required this.restrictions,
  });
}
