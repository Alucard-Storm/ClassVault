import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';

class AuthStateNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final Ref ref;

  AuthStateNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    ref.read(authRepositoryProvider).authStateChanges().listen(
      (user) {
        state = AsyncValue.data(user);
      },
      onError: (err, stack) {
        state = AsyncValue.error(err, stack);
      },
    );
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      state = AsyncValue.data(user);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).logout();
      state = const AsyncValue.data(null);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
      rethrow;
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<AppUser?>>((ref) {
  return AuthStateNotifier(ref);
});
