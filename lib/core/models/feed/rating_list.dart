// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
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

const Map<String, ReactionType> _reactionTypeMap = {
  'like': ReactionType.like,
  'kiss': ReactionType.kiss,
  'laugh': ReactionType.laugh,
  'wonder': ReactionType.wonder,
  'cry': ReactionType.cry,
  'facepalm': ReactionType.facepalm,
  'angry': ReactionType.angry,
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

  static ReactionType? fromString(String value) =>
      _reactionTypeMap[value.toLowerCase()];
}

class RatingList {
  late Map<ReactionType, Set<UserShortInfo>> _ratingList;
  late Map<ReactionType, int> _reactionCounts;

  /// Возвращает список пользователей по типам реакций.
  ///
  /// Обратите внимание:
  /// - Могут присутствовать не все реакции
  /// - Если текущий пользователь поставил реакцию, то он там точно есть
  Map<ReactionType, Set<UserShortInfo>> get ratingList => _ratingList;
  Map<ReactionType, int> get reactionCounts => _reactionCounts;

  RatingList() : this.ratingList();

  RatingList.ratingList([Map<ReactionType, Set<UserShortInfo>>? ratingList]) {
    ratingList ??= {};
    _ratingList = ratingList;
    _reactionCounts = {
      for (final type in ReactionType.values)
        type: ratingList[type]?.length ?? 0,
    };
  }

  RatingList.reactionCounts({
    Map<ReactionType, int>? reactionCounts,
    (UserShortInfo, ReactionType)? userReaction,
  }) {
    _ratingList = {};
    _reactionCounts = {};

    if (reactionCounts != null) {
      _reactionCounts = Map.from(reactionCounts);
    }

    for (final type in ReactionType.values) {
      _reactionCounts.putIfAbsent(type, () => 0);
    }

    if (userReaction != null) {
      _ratingList[userReaction.$2] = {userReaction.$1};
    }
  }

  void addReactions(
    ReactionType reactionType,
    Set<UserShortInfo> userInfo,
  ) {
    _ratingList.putIfAbsent(reactionType, () => <UserShortInfo>{});
    final countBefore = _ratingList[reactionType]!.length;
    _ratingList[reactionType]!.addAll(userInfo);
    final countAfter = _ratingList[reactionType]!.length;
    final addedCount = countAfter - countBefore;
    if (addedCount > 0) {
      _reactionCounts[reactionType] =
          (_reactionCounts[reactionType] ?? 0) + addedCount;
    }
  }

  int getTotalNumberOfReactions() =>
      _reactionCounts.values.fold(0, (sum, count) => sum + count);

  bool removeReaction(int userId) {
    for (final entry in _ratingList.entries) {
      final reactionType = entry.key;
      final users = entry.value;

      UserShortInfo? userToRemove;
      for (final user in users) {
        if (user.bitrixId == userId) {
          userToRemove = user;
          break;
        }
      }

      if (userToRemove != null) {
        users.remove(userToRemove);
        _reactionCounts[reactionType] =
            (_reactionCounts[reactionType] ?? 0) - 1;

        return true;
      }
    }

    return false;
  }

  int getNumberOfReactions([ReactionType? reactionType]) {
    if (reactionType != null) {
      return _reactionCounts[reactionType] ?? 0;
    }
    return getTotalNumberOfReactions();
  }

  Set<UserShortInfo>? getUsers([ReactionType? reactionType]) {
    if (reactionType != null) {
      final users = _ratingList[reactionType];
      return users != null ? Set<UserShortInfo>.from(users) : null;
    }

    final allUsers = <UserShortInfo>{};
    for (final users in _ratingList.values) {
      allUsers.addAll(users);
    }
    return allUsers;
  }

  ReactionType? getReactionByUser(int bitrixId) {
    for (final entry in _ratingList.entries) {
      if (entry.value.any((user) => user.bitrixId == bitrixId)) {
        return entry.key;
      }
    }
    return null;
  }

  UserShortInfo? getReactionInfoByUser(int bitrixId) {
    for (final entry in _ratingList.entries) {
      for (final user in entry.value) {
        if (user.bitrixId == bitrixId) {
          return user;
        }
      }
    }
    return null;
  }

  factory RatingList.fromJson(JsonMap jsonMap) {
    final Map<ReactionType, Set<UserShortInfo>> ratingList = {};
    final usersList = (jsonMap[_UserInfoJsonKeys.users]! as List)
        .cast<Map<String, Object?>>();

    for (final userMap in usersList) {
      final userInfo = UserShortInfo.fromJson(userMap);
      final userReaction = ReactionType.values.firstWhere(
        (reaction) => reaction
            .toString()
            .endsWith(userMap[_UserInfoJsonKeys.reaction]! as String),
      );

      ratingList.putIfAbsent(userReaction, () => {});
      ratingList[userReaction]!.add(userInfo);
    }
    return RatingList.ratingList(ratingList);
  }

  JsonMap toJson() {
    final List<JsonMap> usersList = [];

    ratingList.forEach((reaction, users) {
      for (final user in users) {
        usersList.add({
          _UserInfoJsonKeys.reaction: reaction.toString().split('.').last,
          ...user.toJson(),
        });
      }
    });

    return {
      _UserInfoJsonKeys.users: usersList,
    };
  }

  factory RatingList.fromBitrixJson(JsonMap jsonMap) {
    final Map<ReactionType, Set<UserShortInfo>> ratingList = {};

    jsonMap.forEach((key, value) {
      if (value is List) {
        final Set<UserShortInfo> userList = {};
        for (final userJson in value) {
          if (userJson is JsonMap) {
            userList.add(UserShortInfo.fromBitrixJson(userJson));
          }
        }
        ratingList[ReactionType.values.firstWhere((e) => e.toString() == key)] =
            userList;
      }
    });

    return RatingList.ratingList(ratingList);
  }
}
