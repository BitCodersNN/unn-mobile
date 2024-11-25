import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/misc/api_helpers/authenticated_api_helper.dart';

final class UnnPortalApiHelper extends AuthenticatedApiHelper {
  UnnPortalApiHelper({
    required authorizationService,
  }) : super(
          authorizationService,
          options: createBaseOptions(
            baseUrl: ApiPaths.unnHost,
            headers: authorizationService.headers,
          ),
        );
}
