part of 'library.dart';

class LastFeedLoadDateTimeProviderImpl implements LastFeedLoadDateTimeProvider {
  static const String _feedTimeStorageKey = 'lastFeedLoadDateTime';

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
      (await _storage.read(key: _feedTimeStorageKey)) ?? '_',
    );
  }

  @override
  Future<bool> isContained() async {
    return await _storage.containsKey(key: _feedTimeStorageKey);
  }

  @override
  Future<void> saveData(DateTime? data) async {
    _storage.write(
      key: _feedTimeStorageKey,
      value: data?.toIso8601String() ?? '_',
    );
    _storedTime = data;
  }
}
