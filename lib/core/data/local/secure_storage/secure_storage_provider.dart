final secureStorageProvider = Provider<ISecureStorage>((ref) {
  // dependency inversion
  final secureStorage = SecureStorage(
    flutterSecureStorage: ref.watch(flutterSecureStorageProvider),
  );
  return secureStorage;
});
