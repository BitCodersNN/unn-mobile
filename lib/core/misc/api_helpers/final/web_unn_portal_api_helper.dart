import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/web_authenticated_api_helper.dart';

final class WebUnnPortalApiHelper extends WebAuthenticatedApiHelper {
  WebUnnPortalApiHelper({
    required super.authorizationService,
  }) : super(
          baseUrl: 'https://${ApiPaths.unnHost}/',
        );
}
