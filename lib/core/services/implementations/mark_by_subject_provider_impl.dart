import 'dart:convert';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/mark_by_subject.dart';
import 'package:unn_mobile/core/services/interfaces/mark_by_subject_provider.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class _OfflineMarkBySubjectProviderKeys {
  static const markBySubject = 'markBySubject';
}

class MarkBySubjectProviderImpl implements MarkBySubjectProvider {
  final _storage = Injector.appInstance.get<StorageService>();

  @override
  Future<Map<int, List<MarkBySubject>>?> getData() async {
    if (!(await isContained())) {
      return null;
    }
    final jsonString = jsonDecode((await _storage.read(
      key: _OfflineMarkBySubjectProviderKeys.markBySubject,
    ))!);
    
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    Map<int, List<MarkBySubject>> recordBook = {};
    jsonMap.forEach((key, value) {
      List<MarkBySubject> marksList = (value as List)
          .map((item) => MarkBySubject.fromJson(item as Map<String, dynamic>))
          .toList();
      recordBook[int.parse(key)] = marksList;
    });
    return recordBook;
  }

  @override
  Future<bool> isContained() async {
    return await _storage.containsKey(
        key: _OfflineMarkBySubjectProviderKeys.markBySubject);
  }

  @override
  Future<void> saveData(Map<int, List<MarkBySubject>>? recordBook) async {
    if (recordBook == null) {
      return;
    }
    Map<String, dynamic> jsonMap = {};
    recordBook.forEach((key, value) {
      List<dynamic> jsonList = value.map((item) => item.toJson()).toList();
      jsonMap[key.toString()] = jsonList;
    });

    String jsonString = json.encode(jsonMap);

    await _storage.write(
      key: _OfflineMarkBySubjectProviderKeys.markBySubject,
      value: jsonEncode(jsonString),
    );
  }
}
