import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper_impl.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';

class UnnApiHelper extends ApiHelperImpl {
  final AuthorizationService? authorizationService;

  UnnApiHelper({
    this.authorizationService,
  }) : super(
          options: createBaseOptions(
            baseUrl: ApiPaths.unnHost,
            headers: authorizationService?.cookie,
          ),
        );
}
