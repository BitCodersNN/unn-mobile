import 'package:unn_mobile/core/services/interfaces/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';

class LastFeedLoadDateTimeProviderImpl implements LastFeedLoadDateTimeProvider {
  final StorageService _storage;

  LastFeedLoadDateTimeProviderImpl(this._storage);

  static const String _feedTimeStorageKey = 'lastFeedLoadDateTime';

  DateTime? _storedTime;

  @override
  Future<DateTime?> getData() async {
    if (!(await isContained())) {
      return null;
    }
    return _storedTime = DateTime.tryParse(
      (await _storage.read(key: _feedTimeStorageKey)) ?? '_',
    );
  }

  @override
  Future<bool> isContained() async {
    return await _storage.containsKey(key: _feedTimeStorageKey);
  }

  @override
  DateTime? get lastFeedLoadDateTime => _storedTime;

  @override
  Future<void> saveData(DateTime? data) async {
    _storage.write(
      key: _feedTimeStorageKey,
      value: data?.toIso8601String() ?? '_',
    );
    _storedTime = data;
  }
}
