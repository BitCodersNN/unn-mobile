class KeysForUserDataJsonConverter {
  static const String user = 'user';
  static const String login = 'login';
  static const String fullname = 'fullname';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String sex = 'sex';
  static const String photo = 'photo';
  static const String orig = 'orig';
}

class UserData {
  final String? _login;
  final String _fullname;
  final String? _email;
  final String? _phone;
  final String _sex;
  final String _urlPhoto;

  UserData(this._login, this._fullname, this._email, this._phone, this._sex, this._urlPhoto);

  String? get login => _login;
  String get fullname => _fullname;
  String? get email => _email;
  String? get phone => _phone;
  String get sex => _sex;
  String get urlPhoto => _urlPhoto;

  factory UserData.fromJson(Map<String, Object?> jsonMap) {
    final userJsonMap = jsonMap[KeysForUserDataJsonConverter.user] as Map<String, Object?>;
    return UserData(
      userJsonMap[KeysForUserDataJsonConverter.login] as String?,
      userJsonMap[KeysForUserDataJsonConverter.fullname] as String,
      userJsonMap[KeysForUserDataJsonConverter.email] as String?,
      userJsonMap[KeysForUserDataJsonConverter.phone] as String?,
      userJsonMap[KeysForUserDataJsonConverter.sex] as String,
      (userJsonMap[KeysForUserDataJsonConverter.photo] as  Map<String, Object?>)[KeysForUserDataJsonConverter.orig] as String
    );
  }

  Map<String, dynamic> toJson() => {
    KeysForUserDataJsonConverter.user: {
        KeysForUserDataJsonConverter.login: _login,
        KeysForUserDataJsonConverter.fullname: _fullname,
        KeysForUserDataJsonConverter.email: _email,
        KeysForUserDataJsonConverter.phone: _phone,
        KeysForUserDataJsonConverter.sex: _sex,
        KeysForUserDataJsonConverter.photo: {
          KeysForUserDataJsonConverter.orig : _urlPhoto,
        },
    }
  };
}
