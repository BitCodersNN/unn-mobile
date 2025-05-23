// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/misc/user/user_functions.dart';
import 'package:unn_mobile/core/models/profile/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/profile_view_model_factory.dart';

class ProfileViewModel extends BaseViewModel {
  static const maxRetryAttempts = 5;
  final ProfileOfCurrentUserService _getCurrentUserService;
  final CurrentUserSyncStorage _currentUserSyncStorage;
  final ProfileService _getProfileService;
  final LoggerService _loggerService;

  bool _isLoading = false;

  bool _hasError = false;

  UserData? _loadedData;

  String? _description;

  ProfileViewModel(
    this._getCurrentUserService,
    this._getProfileService,
    this._loggerService,
    this._currentUserSyncStorage,
  );

  factory ProfileViewModel.cached(ProfileCacheKey key) {
    return Injector.appInstance
        .get<ProfileViewModelFactory>()
        .getViewModel(key);
  }
  factory ProfileViewModel.currentUser() {
    return Injector.appInstance
        .get<ProfileViewModelFactory>()
        .getCurrentUserViewModel();
  }
  String? get avatarUrl => _loadedData?.fullUrlPhoto;

  String get description => _description ?? '';

  String get fullname =>
      _loadedData?.fullname.toString() ?? //
      'Не удалось загрузить';

  bool get hasAvatar => _loadedData?.fullUrlPhoto != null;

  bool get hasError => _hasError;

  String get initials => getUserInitials(_loadedData);

  bool get isLoading => _isLoading;

  void init({
    bool force = false,
    int? userId,
    bool loadCurrentUser = false,
    bool loadFromPost = false,
    bool setBusy = true,
    int retryAttempt = 0,
  }) {
    assert((userId != null) || loadCurrentUser);
    if (force || _loadedData == null) {
      _isLoading = setBusy;
      _hasError = false;
      notifyListeners();
      (loadCurrentUser ? _getCurrentUser() : _getProfile(userId!, loadFromPost))
          .then((data) {
        _loadedData = data;
        _description = switch (data.runtimeType) {
          const (StudentData) => (data as StudentData).eduGroup,
          _ => '',
        };
      }).catchError((error, stack) {
        _loggerService.logError(error, stack);
        if (retryAttempt < maxRetryAttempts) {
          init(
            force: force,
            userId: userId,
            loadCurrentUser: loadCurrentUser,
            loadFromPost: loadFromPost,
            setBusy: setBusy,
            retryAttempt: retryAttempt + 1,
          );
          return;
        }
        if (_loadedData == null) {
          _hasError = true;
        }
      }).whenComplete(() {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  void initFromShortInfo(UserShortInfo info, {bool force = false}) {
    if (_loadedData != null && !force) {
      return;
    }
    final splitName = info.fullname?.split(' ');

    _loadedData = UserData(
      info.bitrixId ?? 0,
      null,
      _generateFullname(splitName ?? []),
      null,
      null,
      '',
      info.photoSrc,
      null,
    );
  }

  Fullname _generateFullname(List<String> splitName) {
    switch (splitName.length) {
      case 0:
        return Fullname(null, null, null);
      case 1:
        return Fullname(splitName.first, null, null);
      case 2:
        return Fullname(splitName.first, splitName.last, null);
      default:
        return Fullname(
          splitName[1],
          [
            splitName.first,
            ...splitName.sublist(2, splitName.length - 1),
          ].join(' '),
          splitName.last,
        );
    }
  }

  Future<UserData?> _getCurrentUser() async {
    final currentUser = await _getCurrentUserService.getProfileOfCurrentUser();
    return currentUser ?? _currentUserSyncStorage.currentUserData;
  }

  Future<UserData?> _getProfile(int userId, bool loadFromPost) async {
    return loadFromPost
        ? await _getProfileService.getProfileByAuthorIdFromPost(
            authorId: userId,
          )
        : await _getProfileService.getProfile(
            userId: userId,
          );
  }
}
