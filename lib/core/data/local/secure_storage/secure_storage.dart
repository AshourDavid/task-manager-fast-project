class SecureStorage implements ISecureStorage {
  final FlutterSecureStorage flutterSecureStorage;
  SecureStorage({required this.flutterSecureStorage});
  @override
  Future<void> delete({required String key}) async {
    try {
      await flutterSecureStorage.delete(key: key);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      return await flutterSecureStorage.read(key: key);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await flutterSecureStorage.write(key: key, value: value);
    } catch (e) {
      rethrow;
    }
  }
}
