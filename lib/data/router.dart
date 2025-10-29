import 'package:flutter_application_1/screens/main_tma_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_1/data/auth/auth_notifier.dart';
// Импорт экранов
import 'package:flutter_application_1/screens/university_selection_screen.dart';
import 'package:flutter_application_1/screens/group_selection_screen.dart'; // Новый экран выбора группы

// --- Список всех маршрутов ---
class AppRoutes {
  static const universitySelection =
      '/'; // Оставим как начальный экран (публичный)
  static const groupSelection = '/select-group'; // Путь для выбора группы
  static const quest = '/quest'; // Главный экран - это контейнер с вкладками
  // Устаревшие маршруты
  static const quiz = '/quiz-tab';
  static const scanQr = '/scan-qr-tab';
  static const arScanner = '/ar-scan-tab';
  static const score = '/score-tab';
}

// Провайдер, который предоставляет экземпляр GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  // Получаем текущее состояние авторизации и группу пользователя
  final authAsync = ref.watch(authNotifierProvider);
  // В TWA мы всегда считаем, что пользователь аутентифицирован (имеет Telegram ID)
  final userIsIdentified = authAsync.value?.userId != null;
  final userHasGroup = authAsync.value?.groupId != null;

  // Флаг для отслеживания состояния инициализации
  final isInitializing = authAsync.isLoading;

  return GoRouter(
    initialLocation: AppRoutes.groupSelection,

    redirect: (context, state) {
      // 1. Пока идет инициализация (загрузка Telegram ID и Firestore данных)
      if (isInitializing) return null;

      final goingToSelection = state.matchedLocation.startsWith(
        AppRoutes.groupSelection,
      );

      // || state.matchedLocation.startsWith(AppRoutes.universitySelection);

      // 2. Пользователь идентифицирован (есть Telegram ID), но не выбрал группу
      if (userIsIdentified && !userHasGroup) {
        // Если пытается перейти куда-то кроме выбора группы, перенаправляем на выбор группы
        if (!state.matchedLocation.startsWith(AppRoutes.groupSelection)) {
          return AppRoutes.groupSelection;
        }
      }

      // 3. Пользователь идентифицирован И выбрал группу
      if (userIsIdentified && userHasGroup) {
        // Если пытается вернуться на экраны выбора (группы или вуза), перенаправляем на главный квест
        if (goingToSelection) {
          return AppRoutes.quest;
        }
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
      // 2. Выбор Группы (теперь это обязательный шаг после получения ID)
      GoRoute(
        path: AppRoutes.groupSelection,
        builder: (context, state) => const GroupSelectionScreen(),
      ),

      GoRoute(
        path: AppRoutes.quest,
        builder: (context, state) => const MainTmaScreen(),
      ),
    ],
  );
});
