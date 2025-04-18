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
        avatar: json['avatar'],
        rename: json['rename'],
        extend: json['extend'],
        call: json['call'],
        mute: json['mute'],
        leave: json['leave'],
        leaveOwner: json['leave_owner'],
        send: json['send'],
        userList: json['user_list'],
      );
}
