import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class MainPageViewModel extends BaseViewModel {
  final LoggerService _loggerService;
  final GettingProfileOfCurrentUser _gettingCurrentUser;
  final CurrentUserSyncStorage _currentUserSyncStorage;

  String _userNameAndSurname = '';
  String _userGroup = '';

  ImageProvider<Object>? _userAvatar;

  String? _avatarUrl;

  MainPageViewModel(
    this._gettingCurrentUser,
    this._currentUserSyncStorage,
    this._loggerService,
  );

  String? get avatarUrl => _avatarUrl;
  ImageProvider<Object>? get userAvatar => _userAvatar;
  String get userGroup => _userGroup;
  String get userNameAndSurname => _userNameAndSurname;

  void init() {
    setState(ViewState.busy);
    // _feedUpdaterService.updateFeed();
    _gettingCurrentUser.getProfileOfCurrentUser().then(
      (value) {
        value = value ?? _currentUserSyncStorage.currentUserData;
        if (value == null) {
          setState(ViewState.idle);
          return;
        }
        _userNameAndSurname = '${value.name} ${value.lastname}';
        _userAvatar = value.fullUrlPhoto == null
            ? null
            : CachedNetworkImageProvider(value.fullUrlPhoto!);
        if (value is StudentData) {
          final StudentData studentProfile = value;

          _userGroup = studentProfile.eduGroup;
        }
        setState(ViewState.idle);
      },
    ).onError(
      (error, stackTrace) {
        _loggerService.logError(error, stackTrace);
        setState(ViewState.idle);
      },
    );
  }
}
