// 🔑 Теперь используем MainTmaScreen
import 'package:flutter_application_1/screens/main_tma_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_1/data/auth/auth_notifier.dart';
// Импорт экранов
import 'package:flutter_application_1/screens/university_selection_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';

// --- Список всех маршрутов ---
class AppRoutes {
  static const universitySelection =
      '/'; // Оставим как начальный экран (публичный)
  static const login = '/auth'; // Экрана авторизации (публичный)
  // 🔑 Главный экран - это контейнер с вкладками
  static const quest = '/quest';
  // Мы удаляем прямые маршруты к вкладкам, так как они внутри MainTmaScreen:
  static const quiz =
      '/quiz-tab'; // Устаревший, но оставим на всякий случай, если понадобится
  static const scanQr = '/scan-qr-tab'; // Устаревший
  static const arScanner = '/ar-scan-tab'; // Устаревший
  static const score = '/score-tab'; // Устаревший
}

// Провайдер, который предоставляет экземпляр GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  // Получаем текущее состояние авторизации
  final isAuthenticated = ref.watch(
    authNotifierProvider.select(
      (asyncValue) => asyncValue.value != null && asyncValue.value!.isNotEmpty,
    ),
  );

  return GoRouter(
    initialLocation: AppRoutes.universitySelection,

    // 🔑 КЛЮЧЕВОЙ МОМЕНТ: Логика редиректа
    redirect: (context, state) {
      // Защищаем только главный контейнер квеста
      final protectedRoutes = [AppRoutes.quest];
      final goingToProtected = protectedRoutes.any(
        state.matchedLocation.startsWith,
      );

      final goingToPublic =
          state.matchedLocation.startsWith(AppRoutes.universitySelection) ||
          state.matchedLocation.startsWith(AppRoutes.login);

      // 1. Если пользователь не авторизован и пытается зайти на защищенный маршрут:
      if (!isAuthenticated && goingToProtected) {
        return AppRoutes.login; // Перенаправляем на логин
      }

      // 2. Если пользователь авторизован и пытается зайти на публичный маршрут
      if (isAuthenticated && goingToPublic) {
        return AppRoutes.quest; // Перенаправляем на главный экран квеста
      }

      return null; // Разрешаем переход
    },

    // Список всех маршрутов
    routes: [
      // 1. Выбор ВУЗа
      GoRoute(
        path: AppRoutes.universitySelection,
        builder: (context, state) => const UniversitySelectionScreen(),
      ),
      // 2. Логин
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(),
      ),
      // 🔑 3. ГЛАВНЫЙ ЭКРАН - это контейнер с вкладками
      GoRoute(
        path: AppRoutes.quest,
        builder: (context, state) =>
            const MainTmaScreen(), // Используем новый виджет
        // Удаляем все остальные маршруты, так как они теперь являются вкладками
      ),
      // Оставляем пустые маршруты для совместимости, но они не будут использоваться
      // в основном flow. Если они были прописаны в других файлах, их можно удалить.
    ],
  );
});
