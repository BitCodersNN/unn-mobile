// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:unn_mobile/core/misc/json/json_iterable_parser.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/providers/interfaces/grade_book/mark_by_subject_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _OfflineMarkBySubjectProviderKeys {
  static const markBySubject = 'mark_by_subject';
}

class MarkBySubjectProviderImpl implements MarkBySubjectProvider {
  final StorageService _storage;
  final LoggerService _loggerService;

  MarkBySubjectProviderImpl(this._storage, this._loggerService);

  @override
  Future<Map<int, List<MarkBySubject>>?> getData() async {
    if (!(await isContained())) {
      return null;
    }
    final jsonString = jsonDecode(
      (await _storage.read(
        key: _OfflineMarkBySubjectProviderKeys.markBySubject,
      ))!,
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final Map<int, List<MarkBySubject>> gradeBook = {};

    jsonMap.forEach((key, value) {
      gradeBook[int.parse(key)] = parseJsonIterable<MarkBySubject>(
        value,
        MarkBySubject.fromJson,
        _loggerService,
      );
    });

    return gradeBook;
  }

  @override
  Future<bool> isContained() => _storage.containsKey(
        key: _OfflineMarkBySubjectProviderKeys.markBySubject,
      );

  @override
  Future<void> saveData(Map<int, List<MarkBySubject>>? gradeBook) async {
    if (gradeBook == null) {
      return;
    }
    final Map<String, dynamic> jsonMap = {};
    gradeBook.forEach((key, value) {
      final List<dynamic> jsonList =
          value.map((item) => item.toJson()).toList();
      jsonMap[key.toString()] = jsonList;
    });

    final String jsonString = json.encode(jsonMap);

    await _storage.write(
      key: _OfflineMarkBySubjectProviderKeys.markBySubject,
      value: jsonEncode(jsonString),
    );
  }

  @override
  Future<void> removeData() => _storage.remove(
        key: _OfflineMarkBySubjectProviderKeys.markBySubject,
      );
}
