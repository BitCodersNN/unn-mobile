import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/misc/api_helpers/authenticated_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/source_unn_interceptor.dart';

final class UnnSourceApiHelper extends AuthenticatedApiHelper {
  UnnSourceApiHelper({
    required authorizationService,
  }) : super(
          authorizationService,
          options: createBaseOptions(
            host: Host.unnSource,
            headers: authorizationService.headers,
          ),
          interceptors: [SourceUnnInterceptor()],
        );
}
