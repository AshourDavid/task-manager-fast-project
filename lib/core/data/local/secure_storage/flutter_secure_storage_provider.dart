final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  const androidOptions = AndroidOptions();
  const iosOptions = IOSOptions(accessibility: KeychainAccessibility.unlocked);
  return const FlutterSecureStorage(
    iOptions: iosOptions,
    aOptions: androidOptions,
  );
});
