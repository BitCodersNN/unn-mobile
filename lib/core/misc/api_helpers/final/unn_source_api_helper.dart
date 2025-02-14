import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/misc/api_helpers/authenticated_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';

final class UnnSourceApiHelper extends AuthenticatedApiHelper {
  UnnSourceApiHelper({
    required authorizationService,
  }) : super(
          authorizationService,
          options: createBaseOptions(
            host: Host.unnSourceHost,
            headers: authorizationService.headers,
          ),
        );
}
