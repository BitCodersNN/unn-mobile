// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';
import 'dart:io';

import 'package:unn_mobile/core/misc/file_helpers/size_converter.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_file_data.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_link_data.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_material_data.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_learning_downloader_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class SourceItemViewModel extends BaseViewModel {
  final SizeConverter _sizeConverter = SizeConverter();
  FutureOr<void> Function(File file)? onFileDownloaded;

  final DistanceLearningDownloaderService _downloader;
  final DistanceMaterialData _material;
  final DistanceLinkData? _linkData;
  final DistanceFileData? _fileData;
  SourceItemViewModel(
    DistanceMaterialData material,
    this._downloader,
  )   : _material = material,
        _linkData = material is DistanceLinkData ? material : null,
        _fileData = material is DistanceFileData ? material : null;

  bool get isFile => _fileData is DistanceFileData;
  bool get isLink => _linkData is DistanceLinkData;

  String get comment => _material.comment;

  DateTime get dateTime => _material.dateTime;

  String? get link => _linkData?.link;

  String? get fileName => _fileData?.name;

  String? get fileSize => _fileData == null
      ? null
      : _sizeConverter.convertBytesToSize(_fileData!.sizeInBytes).toString() +
          (_sizeConverter.lastUsedUnit?.getUnitString() ?? '');

  FutureOr<void> downloadFile() => busyCallAsync(_downloadFile);

  FutureOr<void> _downloadFile() async {
    if (_fileData == null) {
      return;
    }
    final file = await _downloader.downloadFile(
      fileName: fileName!,
      downloadUrl: _fileData!.downloadUrl,
    );
    if (file != null) {
      await onFileDownloaded?.call(file);
    }
  }
}
