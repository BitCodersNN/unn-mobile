// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';

class OnlineStatusData {
  DateTime? timeOfLastOnline;

  final ValueNotifier<bool> _isOnline = ValueNotifier<bool>(false);

  ValueNotifier<bool> get notifier => _isOnline;

  bool get isOnline => _isOnline.value;

  set isOnline(bool value) {
    _isOnline.value = value;
  }
}
