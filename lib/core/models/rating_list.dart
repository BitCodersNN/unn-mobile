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

class ReactionUserInfo {
  final int _id;
  final String _fullname;
  final String? _photoSrc;

  int get id => _id;
  String get fullname => _fullname;
  String? get photoSrc => _photoSrc;

  ReactionUserInfo(
    this._id,
    this._fullname,
    this._photoSrc,
  );

  factory ReactionUserInfo.fromJson(Map<String, Object?> jsonMap) => ReactionUserInfo(
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
  late Map<ReactionType, List<ReactionUserInfo>> _ratingList;

  Map<ReactionType, List<ReactionUserInfo>> get ratingList => _ratingList;

  RatingList([Map<ReactionType, List<ReactionUserInfo>>? ratingList]) {
    ratingList ??= {};
    _ratingList = ratingList;
  }

  void addReactions(ReactionType reactionType, List<ReactionUserInfo> userInfo) {
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

  List<ReactionUserInfo>? getUsers([ReactionType? reactionType]) {
    if (reactionType != null) {
      return _ratingList[reactionType];
    }

    List<ReactionUserInfo> users = [];
    for (final list in _ratingList.values) {
      users.addAll(list);
    }
    return users;
  }

  factory RatingList.fromJson(Map<String, Object?> jsonMap) {
    Map<ReactionType, List<ReactionUserInfo>> ratingList = {};

    jsonMap.forEach((key, value) {
      if (value is List) {
        List<ReactionUserInfo> userList = [];
        for (final userJson in value) {
          if (userJson is Map<String, dynamic>) {
            userList.add(ReactionUserInfo.fromJson(userJson));
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
