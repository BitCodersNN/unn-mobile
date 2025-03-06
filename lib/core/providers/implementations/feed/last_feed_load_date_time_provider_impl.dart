import 'package:unn_mobile/core/providers/interfaces/feed/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';

class _LastFeedLoadDateTimeProviderKeys {
  static const String feedTimeStorageKey = 'lastFeedLoadDateTime';
}

class LastFeedLoadDateTimeProviderImpl implements LastFeedLoadDateTimeProvider {
  final StorageService _storage;

  DateTime? _storedTime;

  LastFeedLoadDateTimeProviderImpl(this._storage);

  @override
  DateTime? get lastFeedLoadDateTime => _storedTime;

  @override
  Future<DateTime?> getData() async {
    if (!(await isContained())) {
      return null;
    }
    return _storedTime = DateTime.tryParse(
      (await _storage.read(
            key: _LastFeedLoadDateTimeProviderKeys.feedTimeStorageKey,
          )) ??
          '_',
    );
  }

  @override
  Future<bool> isContained() async {
    return await _storage.containsKey(
      key: _LastFeedLoadDateTimeProviderKeys.feedTimeStorageKey,
    );
  }

  @override
  Future<void> saveData(DateTime? data) async {
    _storage.write(
      key: _LastFeedLoadDateTimeProviderKeys.feedTimeStorageKey,
      value: data?.toIso8601String() ?? '_',
    );
    _storedTime = data;
  }
}
