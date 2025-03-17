import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class MessageIgnoredKeysProvider
    implements DataProvider<Set<String>> {
  @override
  Future<Set<String>> getData();

  @override
  Future<bool> isContained();

  @override
  Future<void> saveData(Set<String> data);
}
