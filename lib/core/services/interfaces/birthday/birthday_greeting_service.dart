// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/profile/user_data.dart';

abstract interface class BirthdayGreetingService {
  bool isBirthday(UserData user, DateTime today);
  Future<bool> shouldShow(UserData user, DateTime today);
  Future<void> markShown(int userId, DateTime date);
}
