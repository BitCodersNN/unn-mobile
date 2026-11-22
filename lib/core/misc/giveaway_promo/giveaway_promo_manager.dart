// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:unn_mobile/core/misc/giveaway_promo/announcement_environment_provider.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/git/cached_git_resource.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_catalog.dart';
import 'package:unn_mobile/core/providers/interfaces/giveaway_promo/giveaway_promo_provider.dart';
import 'package:unn_mobile/core/repositories/interfaces/git/git_resource_repository.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/giveaway_promo/announcement_image_downloader_service.dart';

class ResolvedAnnouncement {
  final AnnouncementItem item;
  final List<File> imageFiles;

  const ResolvedAnnouncement({required this.item, this.imageFiles = const []});
}

class GiveawayPromoManager {
  final GiveawayPromoProvider _provider;
  final LoggerService _logger;
  final GitResourceRepository<AnnouncementCatalog>? _repository;
  final AnnouncementImageDownloaderService? _imageDownloader;
  final DateTime Function() _now;
  final math.Random _random;
  final Future<AnnouncementEnvironment> Function() _environmentLoader;

  GiveawayPromoManager(
    this._provider,
    this._logger,
    this._repository,
    this._imageDownloader,
    CurrentUserSyncStorage? currentUserStorage, {
    DateTime Function()? now,
    math.Random? random,
    Future<AnnouncementEnvironment> Function()? environmentLoader,
    AnnouncementEnvironmentProvider? environmentProvider,
  }) : _now = now ?? DateTime.now,
       _random = random ?? math.Random(),
       _environmentLoader =
           environmentLoader ??
           (environmentProvider ??
                   AnnouncementEnvironmentProvider(currentUserStorage))
               .load;

  Future<ResolvedAnnouncement?> pickAnnouncementForLaunch() async {
    final cached = await _readCachedCatalog();
    if (_repository != null) {
      unawaited(_refreshRepositoryInBackground());
    }
    if (cached == null) {
      return null;
    }
    final env = await _readEnvironment();
    if (env == null) {
      return null;
    }
    final (statesLoaded, states) = await _readStates();
    if (!statesLoaded) {
      return null;
    }
    final lastPickedId = await _readLastPickedId();
    final now = _now();
    final candidates = <ResolvedAnnouncement>[];
    for (final item in cached.data.allItems) {
      if (!item.enabled ||
          !item.period.isActiveAt(now) ||
          !item.target.matches(env)) {
        continue;
      }
      final state = states[item.id] ?? const AnnouncementUserState();
      if (!item.policy.isEligible(state, now)) {
        continue;
      }
      final imageFiles = await _resolveCachedImages(item.images);
      if (imageFiles == null) {
        continue;
      }
      candidates.add(ResolvedAnnouncement(item: item, imageFiles: imageFiles));
    }
    return _selectCandidate(candidates, lastPickedId);
  }

  Future<void> markShown(String id) async {
    try {
      await _recordShown(id);
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
  }

  Future<void> markActionClicked(String id) async {
    try {
      await _recordActionClicked(id);
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
  }

  Future<void> markDismissed(String id) async {
    try {
      await _recordDismissed(id);
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
  }

  ResolvedAnnouncement? _selectCandidate(
    List<ResolvedAnnouncement> candidates,
    String? lastPickedId,
  ) {
    if (candidates.isEmpty) {
      return null;
    }
    final maxPriority = candidates
        .map((candidate) => candidate.item.priority)
        .reduce(math.max);
    final topTier = candidates
        .where((candidate) => candidate.item.priority == maxPriority)
        .toList(growable: false);
    if (topTier.length == 1) {
      return topTier.first;
    }
    final rotated = lastPickedId == null
        ? const <ResolvedAnnouncement>[]
        : topTier
              .where((candidate) => candidate.item.id != lastPickedId)
              .toList(growable: false);
    final pool = rotated.isNotEmpty ? rotated : topTier;
    return pool[_random.nextInt(pool.length)];
  }

  Future<List<File>?> _resolveCachedImages(List<String> imagePaths) async {
    if (imagePaths.isEmpty) {
      return const [];
    }
    final downloader = _imageDownloader;
    if (downloader == null) {
      return null;
    }
    final files = await Future.wait([
      for (final path in imagePaths) downloader.getCachedFile(path),
    ]);
    return files.any((file) => file == null) ? null : files.cast<File>();
  }

  Future<void> _recordShown(String id) async {
    final current = await _provider.getState(id);
    await _provider.saveState(
      id,
      current.copyWith(
        showCount: current.showCount + 1,
        lastShownAt: _now().toLocal(),
      ),
    );
    await _provider.saveLastPickedId(id);
  }

  Future<void> _recordActionClicked(String id) async {
    final current = await _provider.getState(id);
    await _provider.saveState(id, current.copyWith(actionClicked: true));
  }

  Future<void> _recordDismissed(String id) async {
    final current = await _provider.getState(id);
    await _provider.saveState(id, current.copyWith(dismissed: true));
  }

  Future<CachedGitResource<AnnouncementCatalog>?> _readCachedCatalog() async {
    try {
      return await _repository?.getCached();
    } catch (error, stack) {
      _logger.logError(error, stack);
      return null;
    }
  }

  Future<void> _refreshRepositoryInBackground() async {
    try {
      await _repository?.refresh();
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
  }

  Future<AnnouncementEnvironment?> _readEnvironment() async {
    try {
      return await _environmentLoader();
    } catch (error, stack) {
      _logger.logError(error, stack);
      return null;
    }
  }

  Future<(bool, Map<String, AnnouncementUserState>)> _readStates() async {
    try {
      return (true, await _provider.getStates());
    } catch (error, stack) {
      _logger.logError(error, stack);
      return (false, const <String, AnnouncementUserState>{});
    }
  }

  Future<String?> _readLastPickedId() async {
    try {
      return await _provider.getLastPickedId();
    } catch (error, stack) {
      _logger.logError(error, stack);
      return null;
    }
  }
}
