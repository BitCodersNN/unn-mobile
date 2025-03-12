import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class MessageIgnoredKeysProvider
    implements DataProvider<List<String>> {
  @override
  Future<List<String>> getData();

  @override
  Future<bool> isContained();

  @override
  Future<void> saveData(List<String> data);
}
