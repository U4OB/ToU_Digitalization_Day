import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/styles/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Импорт роутера
import 'package:flutter_application_1/data/router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Читаем экземпляр GoRouter из провайдера
    final goRouter = ref.watch(goRouterProvider);

    Firebase.initializeApp();

    return MaterialApp.router(
      // 2. Используем MaterialApp.router
      title: 'ToU',
      theme: AppThemes.darkTheme,
      routerConfig: goRouter, // 3. Передаем конфигурацию роутера
      // Убираем home: QuestScreen()
    );
  }
}
