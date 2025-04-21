import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/authenticated_api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_timeout_and_expected_type_factory.dart';
import 'package:unn_mobile/core/misc/response_status_validator.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_file_sender_service.dart';
import 'package:uuid/uuid.dart';

class _DataKeys {
  static const String sessid = 'sessid';
  static const String chatId = 'chat_id';
  static const String id = 'id';
  static const String data = 'data';
  static const String name = 'NAME';
  static const String fileContent = 'fileContent';
  static const String generateUniqueName = 'generateUniqueName';
  static const String message = 'message';
  static const String templateId = 'template_id';
  static const String asFile = 'as_file';
  static const String uploadId = 'upload_id';
}

class _JsonKeys {
  static const String result = 'result';
  static const String id = 'ID';
}

class MessageFileSenderServiceImpl implements MessageFileSenderService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  MessageFileSenderServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<FileData?> sendFile({
    required int chatId,
    required File file,
    required String text,
  }) async {
    return (await sendFiles(chatId: chatId, files: [file], text: text))?.first;
  }

  @override
  Future<List<FileData>?> sendFiles({
    required int chatId,
    required List<File> files,
    required String text,
  }) async {
    final folderId = await _getFolder(chatId);
    if (folderId == null) return null;

    final successfulFiles = await _uploadFiles(folderId, files);
    if (successfulFiles.isEmpty) return null;

    final requestData = _prepareRequestData(chatId, text, successfulFiles);
    final commitSuccess = await _commitFiles(requestData);

    return commitSuccess ? successfulFiles : null;
  }

  Future<int?> _getFolder(int chatId) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.diskFolder,
        data: {
          _DataKeys.sessid: (_apiHelper as AuthenticatedApiHelper).sessionId,
          _DataKeys.chatId: chatId,
        },
        options: OptionsWithTimeoutAndExpectedTypeFactory.options(
          10,
          ResponseDataType.jsonMap,
        ),
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }
    return response.data[_JsonKeys.result][_JsonKeys.id];
  }

  Future<List<FileData>> _uploadFiles(int folderId, List<File> files) async {
    final uploadFutures = files
        .map(
          (file) => _uploadFile(folderId, file).catchError(
            (exception, stackTrace) {
              _loggerService.logError(exception, stackTrace);
              return null;
            },
          ),
        )
        .toList();

    final fileDataList = await Future.wait(uploadFutures);
    return fileDataList
        .where((fileData) => fileData != null)
        .cast<FileData>()
        .toList();
  }

  Future<FileData?> _uploadFile(int folderId, File file) async {
    try {
      final response = await _apiHelper.post(
        path: ApiPath.uploadfile,
        queryParameters: {
          _DataKeys.sessid: (_apiHelper as AuthenticatedApiHelper).sessionId,
        },
        data: {
          _DataKeys.id: folderId,
          _DataKeys.data: {
            _DataKeys.name: path.basename(file.path),
          },
          _DataKeys.fileContent: [
            path.basename(file.path),
            base64Encode(await file.readAsBytes()),
          ],
          _DataKeys.generateUniqueName: true,
        },
      );

      if (!ResponseStatusValidator.validate(response.data, _loggerService)) {
        return null;
      }

      return FileData.fromBitrixJson(response.data[_JsonKeys.result]);
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return null;
    }
  }

  Map<String, dynamic> _prepareRequestData(
    int chatId,
    String text,
    List<FileData> successfulFiles,
  ) {
    final requestData = {
      _DataKeys.sessid: (_apiHelper as AuthenticatedApiHelper).sessionId,
      _DataKeys.chatId: chatId,
      _DataKeys.message: text,
      _DataKeys.templateId: const Uuid().v4(),
      _DataKeys.asFile: 'Y',
    };

    for (int i = 0; i < successfulFiles.length; i++) {
      requestData['${_DataKeys.uploadId}[$i]'] = successfulFiles[i].id;
    }

    return requestData;
  }

  Future<bool> _commitFiles(Map<String, dynamic> requestData) async {
    try {
      await _apiHelper.post(
        path: ApiPath.fileCommit,
        data: requestData,
      );
    } catch (exception, stackTrace) {
      _loggerService.logError(exception, stackTrace);
      return false;
    }
    return true;
  }
}
