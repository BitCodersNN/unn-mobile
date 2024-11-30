import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/web_authenticated_api_helper.dart';

final class WebUnnMobileApiHelper extends WebAuthenticatedApiHelper {
  WebUnnMobileApiHelper({
    required super.authorizationService,
  }) : super(
          baseUrl: 'https://${ApiPaths.unnMobileHost}/',
        );
}
