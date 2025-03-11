import 'dart:async';

import 'package:unn_mobile/core/misc/file_helpers/size_converter.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_file_data.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_link_data.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_material_data.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class SourceItemViewModel extends BaseViewModel {
  final SizeConverter _sizeConverter = SizeConverter();

  final DistanceMaterialData _material;
  final DistanceLinkData? _linkData;
  final DistanceFileData? _fileData;
  SourceItemViewModel(DistanceMaterialData material)
      : _material = material,
        _linkData = material as DistanceLinkData,
        _fileData = material as DistanceFileData;

  bool get isFile => _fileData != null;
  bool get isLink => _linkData != null;

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
  }
}
