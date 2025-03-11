import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';

class _UserDataJsonKeys {
  static const String bitrixId = 'bitrix_id';
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
  static const String notes = 'notes';
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

  @override
  String toString() => [lastname, name, surname]
      .where((part) => part != null && part.isNotEmpty)
      .join(' ');
}

class UserData {
  static final String _urlPhotoFirstPart =
      '${ProtocolType.https.name}://${Host.unn}';

  final int _bitrixId;
  final String? _login;
  final Fullname _fullname;
  final String? _email;
  final String? _phone;
  final String _sex;
  final String? _notes;
  final String? _urlPhoto;

  const UserData(
    this._bitrixId,
    this._login,
    this._fullname,
    this._email,
    this._phone,
    this._sex,
    this._urlPhoto,
    this._notes,
  );

  int get bitrixId => _bitrixId;
  String? get login => _login;
  Fullname get fullname => _fullname;
  String? get name => _fullname.name;
  String? get lastname => _fullname.lastname;
  String? get surname => _fullname.surname;
  String? get email => _email;
  String? get phone => _phone;
  String get sex => _sex;
  String? get notes => _notes;
  String? get urlPhoto => _urlPhoto;
  String? get fullUrlPhoto {
    if (_urlPhoto == null) {
      return null;
    }
    if (_urlPhoto == 'https://portal.unn.ru') {
      return null;
    }
    if (_urlPhoto!.startsWith(ProtocolType.https.name)) {
      return _urlPhoto!;
    }
    return _urlPhotoFirstPart + _urlPhoto!;
  }

  factory UserData.fromJson(Map<String, Object?> jsonMap) {
    final userJsonMap = jsonMap[_UserDataJsonKeys.user] as Map<String, Object?>;
    return UserData(
      userJsonMap[_UserDataJsonKeys.bitrixId] as int,
      userJsonMap[_UserDataJsonKeys.login] as String?,
      Fullname(
        userJsonMap[_UserDataJsonKeys.name] as String?,
        userJsonMap[_UserDataJsonKeys.lastname] as String?,
        userJsonMap[_UserDataJsonKeys.surname] as String?,
      ),
      userJsonMap[_UserDataJsonKeys.email] as String?,
      userJsonMap[_UserDataJsonKeys.phone] as String?,
      userJsonMap[_UserDataJsonKeys.sex] as String,
      (userJsonMap[_UserDataJsonKeys.photo]
          as Map<String, Object?>)[_UserDataJsonKeys.orig] as String?,
      userJsonMap[_UserDataJsonKeys.notes] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        _UserDataJsonKeys.user: {
          _UserDataJsonKeys.bitrixId: _bitrixId,
          _UserDataJsonKeys.login: _login,
          _UserDataJsonKeys.name: _fullname.name,
          _UserDataJsonKeys.lastname: _fullname.lastname,
          _UserDataJsonKeys.surname: _fullname.surname,
          _UserDataJsonKeys.email: _email,
          _UserDataJsonKeys.phone: _phone,
          _UserDataJsonKeys.sex: _sex,
          _UserDataJsonKeys.notes: _notes,
          _UserDataJsonKeys.photo: {
            _UserDataJsonKeys.orig: _urlPhoto,
          },
        },
      };
}
