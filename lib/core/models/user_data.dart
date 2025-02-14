import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';

class _KeysForUserDataJsonConverter {
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
  String? get fullUrlPhoto => _urlPhoto != null
      ? (_urlPhoto!.startsWith('https:') ? '' : _urlPhotoFirstPart) + _urlPhoto!
      : null;

  factory UserData.fromJson(Map<String, Object?> jsonMap) {
    final userJsonMap =
        jsonMap[_KeysForUserDataJsonConverter.user] as Map<String, Object?>;
    return UserData(
      userJsonMap[_KeysForUserDataJsonConverter.bitrixId] as int,
      userJsonMap[_KeysForUserDataJsonConverter.login] as String?,
      Fullname(
        userJsonMap[_KeysForUserDataJsonConverter.name] as String?,
        userJsonMap[_KeysForUserDataJsonConverter.lastname] as String?,
        userJsonMap[_KeysForUserDataJsonConverter.surname] as String?,
      ),
      userJsonMap[_KeysForUserDataJsonConverter.email] as String?,
      userJsonMap[_KeysForUserDataJsonConverter.phone] as String?,
      userJsonMap[_KeysForUserDataJsonConverter.sex] as String,
      (userJsonMap[_KeysForUserDataJsonConverter.photo]
              as Map<String, Object?>)[_KeysForUserDataJsonConverter.orig]
          as String?,
      userJsonMap[_KeysForUserDataJsonConverter.notes] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        _KeysForUserDataJsonConverter.user: {
          _KeysForUserDataJsonConverter.bitrixId: _bitrixId,
          _KeysForUserDataJsonConverter.login: _login,
          _KeysForUserDataJsonConverter.name: _fullname.name,
          _KeysForUserDataJsonConverter.lastname: _fullname.lastname,
          _KeysForUserDataJsonConverter.surname: _fullname.surname,
          _KeysForUserDataJsonConverter.email: _email,
          _KeysForUserDataJsonConverter.phone: _phone,
          _KeysForUserDataJsonConverter.sex: _sex,
          _KeysForUserDataJsonConverter.notes: _notes,
          _KeysForUserDataJsonConverter.photo: {
            _KeysForUserDataJsonConverter.orig: _urlPhoto,
          },
        },
      };
}
