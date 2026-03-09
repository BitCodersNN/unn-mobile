import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/constants/string_keys/session_identifier_keys.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/stream_auth_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class StreamAuthServiceImpl implements StreamAuthService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  static final _bitrixPatterns = Map<String, RegExp>.unmodifiable({
    SessionIdentifierKeys.assetsCheckSum:
        RegularExpressions.sonetLAssetsCheckSumRegExp,
    SessionIdentifierKeys.signedParameters:
        RegularExpressions.signedParametersRegExp,
    SessionIdentifierKeys.commentFormUID:
        RegularExpressions.commentFormUIDRegExp,
    SessionIdentifierKeys.blogCommentFormUID:
        RegularExpressions.blogCommentFormUIDRegExp,
  });

  Map<String, String>? _streamAuth;

  @override
  Map<String, String>? get streamAuth => _streamAuth;

  @override
  String? get sonetLAssetsCheckSum =>
      _streamAuth?[SessionIdentifierKeys.assetsCheckSum];

  @override
  String? get signedParameters =>
      _streamAuth?[SessionIdentifierKeys.signedParameters];

  @override
  String? get commentFormUID =>
      _streamAuth?[SessionIdentifierKeys.commentFormUID];

  @override
  String? get blogCommentFormUID =>
      _streamAuth?[SessionIdentifierKeys.blogCommentFormUID];

  StreamAuthServiceImpl(this._loggerService, this._apiHelper);

  @override
  Future<Map<String, String>?> getStreamAuthParams() async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.stream,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }
    return _streamAuth = _extractBitrixValues(response.data);
  }

  Map<String, String> _extractBitrixValues(String htmlContent) {
    final result = <String, String>{};

    for (final entry in _bitrixPatterns.entries) {
      final match = entry.value.firstMatch(htmlContent);
      final value = match?.group(1);

      if (value != null && value.isNotEmpty) {
        result[entry.key] = value;
      }
    }

    return result;
  }
}
