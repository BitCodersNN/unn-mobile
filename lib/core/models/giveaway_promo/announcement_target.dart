// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:math' as math;

import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_enums.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_keys.dart';

class AnnouncementEnvironment {
  final String appVersion;
  final int buildNumber;
  final bool isTesting;
  final String storeName;
  final String platform;
  final Type? userType;

  const AnnouncementEnvironment({
    required this.appVersion,
    required this.buildNumber,
    required this.isTesting,
    required this.storeName,
    required this.platform,
    this.userType,
  });
}

class AnnouncementTarget {
  final AnnouncementUserType userType;
  final AnnouncementChannel channel;
  final List<String>? platforms;
  final List<String>? stores;
  final String? minVersion;
  final String? maxVersion;
  final int? minBuild;
  final int? maxBuild;

  const AnnouncementTarget({
    this.userType = AnnouncementUserType.all,
    this.channel = AnnouncementChannel.all,
    this.platforms,
    this.stores,
    this.minVersion,
    this.maxVersion,
    this.minBuild,
    this.maxBuild,
  });

  factory AnnouncementTarget.fromJson(Object? json) {
    if (json is! JsonMap) {
      return const AnnouncementTarget();
    }
    return AnnouncementTarget(
      userType: AnnouncementUserType.fromName(
        json[AnnouncementJsonKeys.userType] as String?,
      ),
      channel: AnnouncementChannel.fromName(
        json[AnnouncementJsonKeys.channel] as String?,
      ),
      platforms: parseJsonStringList(json[AnnouncementJsonKeys.platforms]),
      stores: parseJsonStringList(json[AnnouncementJsonKeys.stores]),
      minVersion: readOptionalTrimmedString(
        json[AnnouncementJsonKeys.minVersion],
      ),
      maxVersion: readOptionalTrimmedString(
        json[AnnouncementJsonKeys.maxVersion],
      ),
      minBuild: parseJsonInt(json[AnnouncementJsonKeys.minBuild]),
      maxBuild: parseJsonInt(json[AnnouncementJsonKeys.maxBuild]),
    );
  }

  bool matches(AnnouncementEnvironment env) {
    if (!userType.matches(env.userType)) {
      return false;
    }
    if (!channel.matches(isTesting: env.isTesting)) {
      return false;
    }
    if (platforms != null && platforms!.isNotEmpty) {
      final envPlatform = env.platform.trim().toLowerCase();
      if (!platforms!.any(
        (platform) => platform.trim().toLowerCase() == envPlatform,
      )) {
        return false;
      }
    }
    if (stores != null && stores!.isNotEmpty) {
      final envStore = _normalizeToken(env.storeName);
      if (!stores!.any((store) => _normalizeToken(store) == envStore)) {
        return false;
      }
    }
    if (minBuild != null && env.buildNumber < minBuild!) {
      return false;
    }
    if (maxBuild != null && env.buildNumber > maxBuild!) {
      return false;
    }
    if (minVersion != null && compareSemver(env.appVersion, minVersion!) < 0) {
      return false;
    }
    if (maxVersion != null && compareSemver(env.appVersion, maxVersion!) > 0) {
      return false;
    }
    return true;
  }

  static int compareSemver(String a, String b) {
    final partsA = _parseSemverParts(a);
    final partsB = _parseSemverParts(b);
    final length = math.max(partsA.length, partsB.length);
    for (var i = 0; i < length; i++) {
      final partA = i < partsA.length ? partsA[i] : 0;
      final partB = i < partsB.length ? partsB[i] : 0;
      if (partA != partB) {
        return partA.compareTo(partB);
      }
    }
    return 0;
  }

  static List<int> _parseSemverParts(String version) {
    final match = RegularExpressions.semverPrefixRegExp.firstMatch(
      version.trim(),
    );
    if (match == null) {
      return const [0];
    }
    return match
        .group(1)!
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList(growable: false);
  }

  static String _normalizeToken(String value) =>
      value.trim().toLowerCase().replaceAll(' ', '');

  JsonMap toJson() => {
    AnnouncementJsonKeys.userType: userType.value,
    AnnouncementJsonKeys.channel: channel.value,
    if (platforms != null) AnnouncementJsonKeys.platforms: platforms,
    if (stores != null) AnnouncementJsonKeys.stores: stores,
    if (minVersion != null) AnnouncementJsonKeys.minVersion: minVersion,
    if (maxVersion != null) AnnouncementJsonKeys.maxVersion: maxVersion,
    if (minBuild != null) AnnouncementJsonKeys.minBuild: minBuild,
    if (maxBuild != null) AnnouncementJsonKeys.maxBuild: maxBuild,
  };
}
