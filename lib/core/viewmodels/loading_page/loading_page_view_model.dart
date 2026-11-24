// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:unn_mobile/core/misc/authorisation/authorisation_request_result.dart';
import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/birthday/birthday_greeting_catalog.dart';
import 'package:unn_mobile/core/models/loading_page/loading_page_catalog.dart';
import 'package:unn_mobile/core/models/loading_page/loading_page_data.dart';
import 'package:unn_mobile/core/repositories/interfaces/git/git_resource_repository.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/logo_downloader_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

enum LoadingRouteTarget { auth, main }

class LoadingPageViewModel extends BaseViewModel {
  final LoggerService _loggerService;
  final AuthRefreshService _initializingApplicationService;
  final GitResourceRepository<LoadingPageCatalog> _loadingPages;
  final LogoDownloaderService _logos;
  final CurrentUserSyncStorage _typeOfCurrentUser;
  final GitResourceRepository<BirthdayGreetingCatalog> _birthdayCatalog;

  LoadingPageModel? _actualLoadingPage;
  File? _logoImage;

  LoadingPageViewModel(
    this._loggerService,
    this._initializingApplicationService,
    this._loadingPages,
    this._logos,
    this._typeOfCurrentUser,
    this._birthdayCatalog,
  );

  LoadingPageModel get loadingPageData =>
      _actualLoadingPage ?? const LoadingPageModel();

  File? get logoImage => _logoImage;

  Future<LoadingRouteTarget> decideRoute({
    required Future<void> loadingPageReady,
  }) async {
    final ready = _waitForLoadingPage(loadingPageReady);
    final target = await _init();
    await ready;
    return target;
  }

  Future<void> _waitForLoadingPage(Future<void> ready) async {
    try {
      await ready;
    } catch (error, stack) {
      _loggerService.logError(error, stack);
    }
  }

  Future<void> initLoadingPages({
    required Brightness brightness,
    required String palette,
  }) async {
    final cached = await _loadingPages.get();
    final resource = cached?.data.isCurrentFormat == false
        ? await _loadingPages.refresh() ?? cached
        : cached;
    final page = resource?.data.pageForDate(
      DateTime.now(),
      brightness: brightness,
      palette: palette,
    );
    _actualLoadingPage = page;
    final logoPath = page?.imagePath;
    _logoImage = logoPath == null
        ? null
        : await _logos.downloadFile(
            logoPath,
            revision: resource?.sha ?? GitPath.branch,
          );
  }

  Future<LoadingRouteTarget> _init() async {
    AuthRequestResult? authRequestResult;

    unawaited(_birthdayCatalog.refresh());

    unawaited(_loadingPages.refresh());

    try {
      authRequestResult = await _initializingApplicationService.refreshLogin();
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }
    final target = switch (authRequestResult) {
      null => LoadingRouteTarget.auth,
      AuthRequestResult.success => LoadingRouteTarget.main,
      AuthRequestResult.noInternet => LoadingRouteTarget.main,
      AuthRequestResult.wrongCredentials => LoadingRouteTarget.auth,
      AuthRequestResult.unknown => LoadingRouteTarget.auth,
    };

    if (target == LoadingRouteTarget.main) {
      await _initUserData();
    }

    return target;
  }

  Future<void> _initUserData() async {
    await _typeOfCurrentUser.updateCurrentUserInfo();
    if (_typeOfCurrentUser.currentUserData != null &&
        _typeOfCurrentUser.currentUserData!.photoSrc != null) {
      unawaited(
        DefaultCacheManager().downloadFile(
          _typeOfCurrentUser.currentUserData!.photoSrc!,
        ),
      );
    }
  }
}
