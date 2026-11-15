// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/distance_learning/distance_course.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_learning_downloader_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_item_view_model.dart';

class SourceCourseViewModel extends BaseViewModel {
  final DistanceCourse _course;
  final DistanceLearningDownloaderService _downloader;

  SourceCourseViewModel(DistanceCourse course, this._downloader)
    : _course = course;

  String get discipline => _course.discipline;

  late final List<SourceItemViewModel> items = [
    for (final material in _course.materials)
      SourceItemViewModel(material, _downloader),
  ];
}
