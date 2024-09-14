import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/services/interfaces/feed_stream_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class MainPageViewModel extends BaseViewModel {
  final LoggerService _loggerService;
  final GettingProfileOfCurrentUser _gettingCurrentUser;
  final CurrentUserSyncStorage _currentUserSyncStorage;
  final FeedUpdaterService _feedUpdaterService;
  String _userNameAndSurname = '';
  String _userGroup = '';

  ImageProvider<Object>? _userAvatar;

  MainPageViewModel(
    this._gettingCurrentUser,
    this._currentUserSyncStorage,
    this._feedUpdaterService,
    this._loggerService,
  );

  String? get avatarUrl => _avatarUrl;
  String? _avatarUrl;
  ImageProvider<Object>? get userAvatar => _userAvatar;
  String get userNameAndSurname => _userNameAndSurname;
  String get userGroup => _userGroup;

  void init() {
    setState(ViewState.busy);
    _feedUpdaterService.updateFeed();
    _gettingCurrentUser.getProfileOfCurrentUser().then(
      (value) {
        value = value ?? _currentUserSyncStorage.currentUserData;
        if (value == null) {
          setState(ViewState.idle);
          return;
        }
        if (value is StudentData) {
          final StudentData studentProfile = value;
          _userNameAndSurname =
              '${studentProfile.name} ${studentProfile.lastname}';
          _userGroup = studentProfile.eduGroup;
          _userAvatar = studentProfile.fullUrlPhoto == null
              ? null
              : CachedNetworkImageProvider(studentProfile.fullUrlPhoto!);
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
