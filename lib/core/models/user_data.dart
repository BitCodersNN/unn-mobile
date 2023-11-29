class KeysForUserDataJsonConverter {
  static const String user = 'user';
  static const String login = 'login';
  static const String name = 'name';
  static const String lastname = 'lastname';
  static const String surname = 'surname';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String sex = 'sex';
  static const String photo = 'photo';
  static const String orig = 'orig';
}

class Fullname {
  final String? _name;
  final String? _lastname;
  final String? _surname;

  Fullname(String? name, String? lastname, String? surname)
      : _name = name,
        _lastname = lastname,
        _surname = surname;

  String? get name => _name;
  String? get lastname => _lastname;
  String? get surname => _surname;
}

class UserData {
  final String? _login;
  final Fullname _fullname;
  final String? _email;
  final String? _phone;
  final String _sex;
  final String _urlPhotoFirstPart = 'https://portal.unn.ru';
  final String? _urlPhoto;

  const UserData(this._login, this._fullname, this._email, this._phone, this._sex,
      this._urlPhoto);

  String? get login => _login;
  Fullname get fullname => _fullname;
  String? get name => _fullname.name;
  String? get lastname => _fullname.lastname;
  String? get surname => _fullname.surname;
  String? get email => _email;
  String? get phone => _phone;
  String get sex => _sex;
  String? get urlPhoto => _urlPhoto;
  String? get fullUrlPhoto => _urlPhoto != null ? _urlPhotoFirstPart + _urlPhoto! : null;


  factory UserData.fromJson(Map<String, Object?> jsonMap) {
    final userJsonMap =
        jsonMap[KeysForUserDataJsonConverter.user] as Map<String, Object?>;
    return UserData(
        userJsonMap[KeysForUserDataJsonConverter.login] as String?,
        Fullname(
            userJsonMap[KeysForUserDataJsonConverter.name] as String?,
            userJsonMap[KeysForUserDataJsonConverter.lastname] as String?,
            userJsonMap[KeysForUserDataJsonConverter.surname] as String?),
        userJsonMap[KeysForUserDataJsonConverter.email] as String?,
        userJsonMap[KeysForUserDataJsonConverter.phone] as String?,
        userJsonMap[KeysForUserDataJsonConverter.sex] as String,
        (userJsonMap[KeysForUserDataJsonConverter.photo]
                as Map<String, Object?>)[KeysForUserDataJsonConverter.orig]
            as String?);
  }

  Map<String, dynamic> toJson() => {
        KeysForUserDataJsonConverter.user: {
          KeysForUserDataJsonConverter.login: _login,
          KeysForUserDataJsonConverter.name: _fullname.name,
          KeysForUserDataJsonConverter.lastname: _fullname.lastname,
          KeysForUserDataJsonConverter.surname: _fullname.surname,
          KeysForUserDataJsonConverter.email: _email,
          KeysForUserDataJsonConverter.phone: _phone,
          KeysForUserDataJsonConverter.sex: _sex,
          KeysForUserDataJsonConverter.photo: {
            KeysForUserDataJsonConverter.orig: _urlPhoto,
          },
        }
      };
}
