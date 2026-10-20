// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/models/common/online_status_data.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';

class MainPageViewModel extends BaseViewModel {
  final OnlineStatusData _onlineStatusData;
  ProfileViewModel? _profileViewModel;

  MainPageViewModel(this._onlineStatusData);

  ProfileViewModel? get profileViewModel => _profileViewModel;

  bool get isOnline => _onlineStatusData.isOnline;

  FutureOr<void> init() => busyCallAsync(() {
        _profileViewModel = ProfileViewModel.currentUser();
      });
}
