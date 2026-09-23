import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/constants/api/host.dart';

final class RaspApiHelper extends ApiHelper {
  RaspApiHelper()
      : super(
          options: createBaseOptions(
            host: Host.unnRasp,
          ),
        );
}
