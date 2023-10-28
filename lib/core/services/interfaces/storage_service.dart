abstract class StorageService {
  Future<bool> containsKey (String key, bool secure);
  Future<String> read(String key, bool secure);
  Future<void> write(String key, String value, bool secure);
}