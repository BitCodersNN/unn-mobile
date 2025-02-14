import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';

final class GitHubRawApiHelper extends ApiHelper {
  GitHubRawApiHelper()
      : super(
          options: createBaseOptions(
            host: Host.gitHubHost,
          ),
        );
}
