// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

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

  factory ChatRestrictions.fromJson(Map<String, dynamic> json) =>
      ChatRestrictions(
        avatar: json[_ChatRestrictionsJsonKeys.avatar],
        rename: json[_ChatRestrictionsJsonKeys.rename],
        extend: json[_ChatRestrictionsJsonKeys.extend],
        call: json[_ChatRestrictionsJsonKeys.call],
        mute: json[_ChatRestrictionsJsonKeys.mute],
        leave: json[_ChatRestrictionsJsonKeys.leave],
        leaveOwner: json[_ChatRestrictionsJsonKeys.leaveOwner],
        send: json[_ChatRestrictionsJsonKeys.send],
        userList: json[_ChatRestrictionsJsonKeys.userList],
      );

  Map<String, dynamic> toJson() => {
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
