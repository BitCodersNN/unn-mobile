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
}
