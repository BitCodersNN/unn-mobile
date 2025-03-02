import 'package:dio/dio.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_type_interceptor.dart';

class OptionsWithExpectedTypeFactory {
  static Options _optionsWithExpectedType(ResponseDataType responseDataType) =>
      Options(
        extra: mapWithExpectedType(responseDataType),
      );

  static Map<String, dynamic> mapWithExpectedType(
    ResponseDataType responseDataType,
  ) =>
      {
        ResponseTypeInterceptorKey.expectedType: responseDataType,
      };

  static get jsonMap => _optionsWithExpectedType(ResponseDataType.jsonMap);

  static get list => _optionsWithExpectedType(ResponseDataType.list);

  static get string => _optionsWithExpectedType(ResponseDataType.string);
}
