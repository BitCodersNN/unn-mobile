import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/certificate/certificates.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificates_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/certificate_item_view_model.dart';

class CertificatesViewModel extends BaseViewModel {
  final CertificatesService _certificatesService;

  CertificatesViewModel(this._certificatesService);

  bool get hasError => state == ViewState.idle && _certificates == null;

  Certificates? _certificates;

  final List<CertificateItemViewModel> certificates = [];

  void init() {
    setState(ViewState.busy);
    _certificatesService.getCertificates().then(
      (value) {
        _certificates = value;
        certificates.clear();
        _certificates?.certificates.forEach(
          (c) => certificates.add(
            Injector.appInstance.get<CertificateItemViewModel>()..init(c),
          ),
        );
        setState(ViewState.idle);
      },
    );
  }
}
