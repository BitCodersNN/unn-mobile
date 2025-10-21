// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';

class _ChatRestrictionsJsonKeys {
  static const String avatar = 'avatar';
  static const String rename = 'rename';
  static const String extend = 'extend';
  static const String call = 'call';
  static const String mute = 'mute';
  static const String leave = 'leave';
  static const String leaveOwner = 'leave_owner';
  static const String send = 'send';
  static const String userList = 'user_list';
}

class ChatRestrictions {
  final bool avatar;
  final bool rename;
  final bool extend;
  final bool call;
  final bool mute;
  final bool leave;
  final bool leaveOwner;
  final bool send;
  final bool userList;

  ChatRestrictions({
    this.avatar = true,
    this.rename = true,
    this.extend = true,
    this.call = true,
    this.mute = true,
    this.leave = true,
    this.leaveOwner = true,
    this.send = true,
    this.userList = true,
  });

  factory ChatRestrictions.fromJson(JsonMap json) => ChatRestrictions(
        avatar: json[_ChatRestrictionsJsonKeys.avatar]! as bool,
        rename: json[_ChatRestrictionsJsonKeys.rename]! as bool,
        extend: json[_ChatRestrictionsJsonKeys.extend]! as bool,
        call: json[_ChatRestrictionsJsonKeys.call]! as bool,
        mute: json[_ChatRestrictionsJsonKeys.mute]! as bool,
        leave: json[_ChatRestrictionsJsonKeys.leave]! as bool,
        leaveOwner: json[_ChatRestrictionsJsonKeys.leaveOwner]! as bool,
        send: json[_ChatRestrictionsJsonKeys.send]! as bool,
        userList: json[_ChatRestrictionsJsonKeys.userList]! as bool,
      );

  JsonMap toJson() => {
        _ChatRestrictionsJsonKeys.avatar: avatar,
        _ChatRestrictionsJsonKeys.rename: rename,
        _ChatRestrictionsJsonKeys.extend: extend,
        _ChatRestrictionsJsonKeys.call: call,
        _ChatRestrictionsJsonKeys.mute: mute,
        _ChatRestrictionsJsonKeys.leave: leave,
        _ChatRestrictionsJsonKeys.leaveOwner: leaveOwner,
        _ChatRestrictionsJsonKeys.send: send,
        _ChatRestrictionsJsonKeys.userList: userList,
      };
}
