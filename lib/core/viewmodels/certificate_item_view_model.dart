import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:unn_mobile/core/models/certificate/certificate.dart';
import 'package:unn_mobile/core/models/certificate/practice_order.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificate_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificate_path_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class CertificateItemViewModel extends BaseViewModel {
  Certificate? _certificate;
  final CertificatePathService _certificatePathService;
  final CertificateDownloaderService _certificateDownloaderService;

  bool get hasError => state == ViewState.idle && _certificate == null;

  String get name => _certificate?.name ?? '';
  String get description => _certificate?.description ?? '';

  bool get downloadAvailable => _certificate?.certificateSigPath != null;

  bool get isViewExpanded => _isViewExpanded;

  void Function()? onSigDownloaded;

  set isViewExpanded(bool value) {
    _isViewExpanded = value;

    notifyListeners();
  }

  bool _isViewExpanded = false;

  CertificateItemViewModel(
    this._certificatePathService,
    this._certificateDownloaderService,
  );

  void init(Certificate certificate) {
    _certificate = certificate;
    _isViewExpanded = false;
    notifyListeners();
  }

  Future<void> askForPath() async => await busyCallAsync(() async {
        final certificate = _certificate;
        if (_certificate == null) {
          return;
        }
        int num = 0;
        if (certificate is PracticeOrder) {
          num = certificate.num;
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
        await OpenFilex.open(file.path);
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
