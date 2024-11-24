import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper_impl.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';

class GithubApiHelper extends ApiHelperImpl {
  GithubApiHelper()
      : super(
          options: createBaseOptions(
            baseUrl: ApiPaths.gitHubApiHost,
          ),
        );
}
