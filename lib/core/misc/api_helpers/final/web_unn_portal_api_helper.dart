import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/misc/api_helpers/web_authenticated_api_helper.dart';

final class WebUnnPortalApiHelper extends WebAuthenticatedApiHelper {
  WebUnnPortalApiHelper({
    required super.authorizationService,
  }) : super(
          host: Host.unnHost,
        );
}
