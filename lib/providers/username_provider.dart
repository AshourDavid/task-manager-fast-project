import 'package:flutter_riverpod/flutter_riverpod.dart';

final usernameProvider = AsyncNotifierProvider<UsernameNotifier, String>(() => UsernameNotifier());

class UsernameNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    state = const AsyncLoading();
    // Simulate fetching username from storage/API
    await Future.delayed(const Duration(milliseconds: 500));
    return 'User'; // Initial username (replace with actual fetch)
  }

  Future<void> changeUsername(String newUsername) async {
    state = const AsyncLoading();
    // Simulate updating username (API call, local storage, etc.)
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data(newUsername);
  }
}
