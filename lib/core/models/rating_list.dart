class _KeysForUserInfoJsonConverter {
  static const String id = 'USER_ID';
  static const String fullname = 'FULL_NAME';
  static const String photoSrc = 'PHOTO_SRC';
}

enum ReactionType {
  like,
  kiss,
  laugh,
  wonder,
  cry,
  angry,
  facepalm,
}

class UserInfo {
  final int _id;
  final String _fullname;
  final String? _photoSrc;

  int get id => _id;
  String get fullname => _fullname;
  String? get photoSrc => _photoSrc;

  UserInfo(
    this._id,
    this._fullname,
    this._photoSrc,
  );

  factory UserInfo.fromJson(Map<String, Object?> jsonMap) => UserInfo(
        int.parse(jsonMap[_KeysForUserInfoJsonConverter.id] as String),
        jsonMap[_KeysForUserInfoJsonConverter.fullname] as String,
        jsonMap[_KeysForUserInfoJsonConverter.photoSrc] as String?,
      );

  Map<String, dynamic> toJson() => {
        _KeysForUserInfoJsonConverter.id: _id,
        _KeysForUserInfoJsonConverter.fullname: _fullname,
        _KeysForUserInfoJsonConverter.photoSrc: _photoSrc,
      };
}

class RatingList {
  late Map<ReactionType, List<UserInfo>> _ratingList;

  Map<ReactionType, List<UserInfo>> get ratingList => _ratingList;

  RatingList([Map<ReactionType, List<UserInfo>>? ratingList]) {
    ratingList ??= {};
    _ratingList = ratingList;
  }

  void addReactions(ReactionType reactionType, List<UserInfo> userInfo) {
    int initialSize = _ratingList.length;
    _ratingList.putIfAbsent(reactionType, () => userInfo);

    if (_ratingList.length == initialSize) {
      _ratingList[reactionType]!.addAll(userInfo);
    }
  }

  int? getNumberOfReactions([ReactionType? reactionType]) {
    if (reactionType != null) {
      return _ratingList[reactionType]?.length;
    }

    int totalSize = 0;
    for (final list in _ratingList.values) {
      totalSize += list.length;
    }
    return totalSize;
  }

  List<UserInfo>? getUsers([ReactionType? reactionType]) {
    if (reactionType != null) {
      return _ratingList[reactionType];
    }

    List<UserInfo> users = [];
    for (final list in _ratingList.values) {
      users.addAll(list);
    }
    return users;
  }

  factory RatingList.fromJson(Map<String, Object?> jsonMap) {
    Map<ReactionType, List<UserInfo>> ratingList = {};

    jsonMap.forEach((key, value) {
      if (value is List) {
        List<UserInfo> userList = [];
        for (final userJson in value) {
          if (userJson is Map<String, dynamic>) {
            userList.add(UserInfo.fromJson(userJson));
          }
        }
        ratingList[ReactionType.values.firstWhere((e) => e.toString() == key)] =
            userList;
      }
    });

    return RatingList(ratingList);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    _ratingList.forEach((key, value) {
      json[key.toString()] = value.map((user) => user.toJson()).toList();
    });

    return json;
  }
}
