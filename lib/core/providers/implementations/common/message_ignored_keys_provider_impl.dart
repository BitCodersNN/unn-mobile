import 'package:unn_mobile/core/providers/interfaces/common/message_ignored_keys_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class MessageIgnoredKeysProviderImpl implements MessageIgnoredKeysProvider {
  final String _storageKey = 'IgnoredMessages';
  final StorageService _storage;

  MessageIgnoredKeysProviderImpl(this._storage);
  @override
  Future<List<String>> getData() async {
    if (!(await isContained())) {
      return [];
    }

    return (await _storage.read(key: _storageKey))?.split(';') ?? [];
  }

  @override
  Future<bool> isContained() async {
    return await _storage.containsKey(key: _storageKey);
  }

  @override
  Future<void> saveData(List<String> data) async {
    await _storage.write(key: _storageKey, value: data.join(';'));
  }
}
