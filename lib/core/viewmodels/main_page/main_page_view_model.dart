// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';

class MainPageViewModel extends BaseViewModel {
  ProfileViewModel? _profileViewModel;

  ProfileViewModel? get profileViewModel => _profileViewModel;

  FutureOr<void> init() => busyCallAsync(() {
        _profileViewModel = ProfileViewModel.currentUser();
      });
}
