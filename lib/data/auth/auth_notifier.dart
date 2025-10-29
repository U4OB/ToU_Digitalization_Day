import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Модель данных пользователя (с Telegram ID) ---
class UserData {
  // Telegram ID, который используется как userId
  final String userId;
  // Имя и фамилия из Telegram (опционально)
  final String? fullName;
  // Выбранная группа
  final String? groupId;

  UserData({required this.userId, this.fullName, this.groupId});

  UserData copyWith({String? groupId}) {
    return UserData(userId: userId, fullName: fullName, groupId: groupId);
  }
}

class AuthNotifier extends StateNotifier<AsyncValue<UserData?>> {
  // --- MOCK ДАННЫЕ ДЛЯ ТЕСТИРОВАНИЯ ---
  static const String mockTelegramId = 'tg_user_123456789';
  static const String mockFullName = 'Алибек Квестов';

  AuthNotifier() : super(const AsyncValue.loading()) {
    _initializeAuth();
  }

  // Инициализация и получение Telegram ID
  Future<void> _initializeAuth() async {
    try {
      // 1. Имитация получения Telegram User ID (задержка 1с)
      await Future.delayed(const Duration(milliseconds: 500));
      final userId = mockTelegramId;

      // 2. Устанавливаем начальное состояние (группа пока null)
      state = AsyncValue.data(
        UserData(
          userId: userId,
          fullName: mockFullName,
          groupId: null, // Группа пока не выбрана
        ),
      );
      print(
        'AuthNotifier: Аутентификация через Telegram ID ($userId) завершена.',
      );
    } catch (e, st) {
      print('AuthNotifier Error during initialization: $e');
      state = AsyncValue.error(e, st);
    }
  }

  // Обновление группы пользователя после выбора на экране
  Future<void> setGroup(String groupId) async {
    final currentUserData = state.value;
    if (currentUserData == null) {
      state = AsyncValue.error(
        'Пользователь не авторизован',
        StackTrace.current,
      );
      return;
    }

    // Сохраняем группу in-memory
    state.whenData((userData) {
      if (userData != null) {
        state = AsyncValue.data(userData.copyWith(groupId: groupId));
        print(
          'AuthNotifier: Группа пользователя обновлена на $groupId (in-memory).',
        );
      }
    });
  }

  // 🔑 1. Геттер для получения userId (Telegram ID)
  String? get telegramId {
    return state.value?.userId;
  }

  // 🔑 2. Геттер для получения groupId
  String? get groupId {
    return state.value?.groupId;
  }

  // 🔑 3. Метод для сброса группы (имитация выхода/разлогина с сохранением ID)
  void resetGroup() {
    state.whenData((userData) {
      if (userData != null) {
        // Устанавливаем groupId обратно в null, чтобы вернуться на экран выбора группы
        state = AsyncValue.data(userData.copyWith(groupId: null));
        print('AuthNotifier: Группа сброшена. Требуется повторный выбор.');
      }
    });
  }
}

// --- Провайдеры ---

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserData?>>((ref) {
      // Notifier просто создается, инициализация происходит в конструкторе
      return AuthNotifier();
    });
