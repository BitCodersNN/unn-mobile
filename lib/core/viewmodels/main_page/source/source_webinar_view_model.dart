// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/distance_learning/webinar.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class SourceWebinarViewModel extends BaseViewModel {
  final Webinar _webinar;

  SourceWebinarViewModel(this._webinar);

  String get comment => _webinar.comment;
  String get discipline => _webinar.discipline;

  String? get urlRecord => _webinar.urlRecord;
  String? get urlStream => _webinar.urlStream;

  String get title => _webinar.title;

  DateTimeRange get dateTimeRange => _webinar.dateTimeRange;

  bool _expanded = false;

  bool get expanded => _expanded;

  set expanded(bool value) {
    _expanded = value;
    notifyListeners();
  }
}
