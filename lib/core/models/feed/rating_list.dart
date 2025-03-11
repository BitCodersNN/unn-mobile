import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class _UserInfoJsonKeys {
  static const String users = 'users';
  static const String reaction = 'reaction';
}

const String _reactionAssetsDirectory = 'assets/images/reactions';

const Map<ReactionType, String> _reactionAssets = {
  ReactionType.like: '$_reactionAssetsDirectory/active_like.png',
  ReactionType.angry: '$_reactionAssetsDirectory/angry.png',
  ReactionType.cry: '$_reactionAssetsDirectory/sad.png',
  ReactionType.laugh: '$_reactionAssetsDirectory/laugh.png',
  ReactionType.facepalm: '$_reactionAssetsDirectory/facepalm.png',
  ReactionType.kiss: '$_reactionAssetsDirectory/love.png',
  ReactionType.wonder: '$_reactionAssetsDirectory/confused.png',
};

const Map<ReactionType, String> _reactionNames = {
  ReactionType.like: 'Нравится',
  ReactionType.angry: 'Ъуъ!',
  ReactionType.cry: 'Печаль',
  ReactionType.laugh: 'Смешно',
  ReactionType.facepalm: 'Facepalm',
  ReactionType.kiss: 'Восторг',
  ReactionType.wonder: 'Ого!',
};

enum ReactionType {
  like,
  kiss,
  laugh,
  wonder,
  cry,
  facepalm,
  angry,
  ;

  String get assetName => _reactionAssets[this]!;
  String get caption => _reactionNames[this]!;
}

class RatingList {
  late Map<ReactionType, List<UserShortInfo>> _ratingList;

  Map<ReactionType, List<UserShortInfo>> get ratingList => _ratingList;

  RatingList([Map<ReactionType, List<UserShortInfo>>? ratingList]) {
    ratingList ??= {};
    _ratingList = ratingList;
  }

  void addReactions(
    ReactionType reactionType,
    List<UserShortInfo> userInfo,
  ) {
    final int initialSize = _ratingList.length;
    _ratingList.putIfAbsent(reactionType, () => userInfo);

    if (_ratingList.length == initialSize) {
      _ratingList[reactionType]!.addAll(userInfo);
    }
  }

  int getTotalNumberOfReactions() {
    int total = 0;
    for (final element in _ratingList.values) {
      total += element.length;
    }
    return total;
  }

  void removeReaction(
    int userId,
  ) {
    for (final reactionType in _ratingList.keys) {
      final listReactionUserInfo = _ratingList[reactionType] ?? [];
      listReactionUserInfo.removeWhere((element) => element.bitrixId == userId);
    }
  }

  int? getNumberOfReactions([ReactionType? reactionType]) {
    if (reactionType != null) {
      return _ratingList[reactionType]?.length;
    }
    return getTotalNumberOfReactions();
  }

  List<UserShortInfo>? getUsers([ReactionType? reactionType]) {
    if (reactionType != null) {
      return _ratingList[reactionType];
    }

    final List<UserShortInfo> users = [];
    for (final list in _ratingList.values) {
      users.addAll(list);
    }
    return users;
  }

  ReactionType? getReactionByUser(int bitrixId) {
    final entry = _ratingList.entries.firstWhere(
      (entry) => entry.value.any((user) => user.bitrixId == bitrixId),
      orElse: () => const MapEntry(ReactionType.like, []),
    );

    return entry.value.isNotEmpty ? entry.key : null;
  }

  UserShortInfo? getReactionInfoByUser(int bitrixId) {
    final entry = _ratingList.entries.firstWhere(
      (entry) => entry.value.any((user) => user.bitrixId == bitrixId),
      orElse: () => const MapEntry(ReactionType.like, []),
    );
    return entry.value.isNotEmpty
        ? entry.value.firstWhere((element) => element.bitrixId == bitrixId)
        : null;
  }

  factory RatingList.fromJson(Map<String, Object?> jsonMap) {
    final Map<ReactionType, List<UserShortInfo>> ratingList = {};
    final usersList = jsonMap[_UserInfoJsonKeys.users] as List;
    for (final userMap in usersList) {
      final userInfo = UserShortInfo.fromJson(userMap);
      final userReaction = ReactionType.values.firstWhere(
        (reaction) => reaction
            .toString()
            .endsWith(userMap[_UserInfoJsonKeys.reaction]),
      );

      ratingList.putIfAbsent(userReaction, () => []);
      ratingList[userReaction]!.add(userInfo);
    }
    return RatingList(ratingList);
  }

  Map<String, Object?> toJson() {
    final List<Map<String, Object?>> usersList = [];

    ratingList.forEach((reaction, users) {
      for (final user in users) {
        usersList.add({
          _UserInfoJsonKeys.reaction:
              reaction.toString().split('.').last,
          ...user.toJson(),
        });
      }
    });

    return {
      _UserInfoJsonKeys.users: usersList,
    };
  }

  factory RatingList.fromJsonLegacy(Map<String, Object?> jsonMap) {
    final Map<ReactionType, List<UserShortInfo>> ratingList = {};

    jsonMap.forEach((key, value) {
      if (value is List) {
        final List<UserShortInfo> userList = [];
        for (final userJson in value) {
          if (userJson is Map<String, dynamic>) {
            userList.add(UserShortInfo.fromJsonLegacy(userJson));
          }
        }
        ratingList[ReactionType.values.firstWhere((e) => e.toString() == key)] =
            userList;
      }
    });

    return RatingList(ratingList);
  }
}
