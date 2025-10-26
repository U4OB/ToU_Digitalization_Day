import 'dart:async';

import 'package:flutter_application_1/data/auth/auth_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends AsyncNotifier<String> {
  @override
  FutureOr<String> build() async {
    return '';
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    final authRepo = ref.read(authRepositoryProvider);

    try {
      final token = await authRepo.login(username, password);
      state = AsyncValue.data(token);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      await Future.delayed(const Duration(milliseconds: 50));
      state = const AsyncValue.data('');
    }
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, String>(
  () => AuthNotifier(),
);
