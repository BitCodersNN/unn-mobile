import 'dart:convert';

import 'package:unn_mobile/core/models/mark_by_subject.dart';
import 'package:unn_mobile/core/services/interfaces/mark_by_subject_provider.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class _OfflineMarkBySubjectProviderKeys {
  static const markBySubject = 'markBySubject';
}

class MarkBySubjectProviderImpl implements MarkBySubjectProvider {
  final StorageService _storage;

  MarkBySubjectProviderImpl(this._storage);

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
      final List<MarkBySubject> marksList = (value as List)
          .map((item) => MarkBySubject.fromJson(item as Map<String, dynamic>))
          .toList();
      gradeBook[int.parse(key)] = marksList;
    });
    return gradeBook;
  }

  @override
  Future<bool> isContained() async {
    return await _storage.containsKey(
      key: _OfflineMarkBySubjectProviderKeys.markBySubject,
    );
  }

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
}
