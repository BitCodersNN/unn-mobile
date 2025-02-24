import 'dart:io';

import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/models/certificate/certificate.dart';
import 'package:unn_mobile/core/models/certificate/practice_order.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificate_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificate_path_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class CertificateItemViewModel extends BaseViewModel {
  Certificate? _certificate;
  PracticeOrder? _practiceOrder;
  final CertificatePathService _certificatePathService;
  final CertificateDownloaderService _certificateDownloaderService;

  bool get hasError => state == ViewState.idle && _certificate == null;

  String get name =>
      isPractice ? 'Предписание на практику' : _certificate?.name ?? '';
  String get description => _certificate?.description ?? '';

  bool get downloadAvailable => _certificate?.certificateSigPath != null;

  bool get isViewExpanded => _isViewExpanded;

  String? get practiceType => _practiceOrder?.type;

  String? get practiceName => _practiceOrder?.name;

  String? get practiceDates =>
      'с ${_practiceOrder?.practiceDateTimeRange.start.format(DatePattern.ddmmyyyy)} '
      'по ${_practiceOrder?.practiceDateTimeRange.end.format(DatePattern.ddmmyyyy)}';

  void Function()? onSigDownloaded;
  void Function()? onCertificateDownloaded;

  set isViewExpanded(bool value) {
    _isViewExpanded = value;

    notifyListeners();
  }

  bool _isViewExpanded = false;

  bool _isPractice = false;
  bool get isPractice => _isPractice;

  CertificateItemViewModel(
    this._certificatePathService,
    this._certificateDownloaderService,
  );

  void init(Certificate certificate) {
    _isPractice = false;
    _practiceOrder = null; // на всякий случай
    _certificate = certificate;
    if (certificate is PracticeOrder) {
      _isPractice = true;
      _practiceOrder = certificate;
    }
    _isViewExpanded = false;
    notifyListeners();
  }

  Future<void> askForPath() async => await busyCallAsync(() async {
        if (_certificate == null) {
          return;
        }
        int num = 0;
        if (isPractice) {
          num = _practiceOrder!.num;
        }
        final path = await _certificatePathService.getCertificatePath(
          sendtype: _certificate!.sendtype,
          number: num,
        );
        if (path == null) {
          return;
        }

        _certificate = Certificate(
          name: _certificate!.name,
          sendtype: _certificate!.sendtype,
          description: _certificate!.description,
          certificatePath: path,
        );
      });

  Future<void> download() async => await busyCallAsync(() async {
        final file = await _downloadFile(_certificate?.certificatePath);
        if (file == null) {
          return;
        }
        onCertificateDownloaded?.call();
      });

  Future<void> downloadSig() async => await busyCallAsync(() async {
        if (await _downloadFile(_certificate!.certificateSigPath) == null) {
          return;
        }
        onSigDownloaded?.call();
      });

  Future<File?> _downloadFile(String? path) async {
    if (path == null) {
      return null;
    }
    if (!downloadAvailable) {
      return null;
    }
    return await _certificateDownloaderService
        .downloadFile(_certificate!.certificatePath);
  }
}
