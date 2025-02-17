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

  Future<void> receivePath() async => await _busyCall(() async {
        if (_certificate == null) {
          return;
        }
        int num = 0;
        if (_certificate is PracticeOrder) {
          num = (_certificate as PracticeOrder).num;
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

  Future<void> download() async => await _busyCall(() async {
        if (!downloadAvailable) {
          return;
        }
        final file = await _certificateDownloaderService
            .downloadFile(_certificate!.certificatePath);
        if (file == null) {
          return;
        }
        await OpenFilex.open(file.path);
      });

  Future<void> downloadSig() async => await _busyCall(() async {
        if (!downloadAvailable) {
          return;
        }
        final file = await _certificateDownloaderService
            .downloadFile(_certificate!.certificatePath);
        if (file == null) {
          return;
        }
        onSigDownloaded?.call();
      });

  Future<void> _busyCall(Future<void> Function() task) async {
    if (isBusy) {
      return;
    }
    try {
      setState(ViewState.busy);
      await task();
    } finally {
      setState(ViewState.idle);
    }
  }
}
