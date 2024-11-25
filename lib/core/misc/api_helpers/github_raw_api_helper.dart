import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';

final class GitHubRawApiHelper extends BaseApiHelper {
  GitHubRawApiHelper()
      : super(
        options: createBaseOptions(
            baseUrl: ApiPaths.gitHubHost,
          ),
        );
}
