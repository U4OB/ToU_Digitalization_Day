import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/data/auth/auth_notifier.dart';
import 'package:flutter_application_1/presentation/quest/quest_notifier.dart';
import 'package:flutter_application_1/styles/app_theme.dart'; // Добавлен импорт для AppColors

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Читаем состояние аутентификации (AsyncValue<UserData?>)
    final authState = ref.watch(authNotifierProvider);
    // Читаем состояние квеста
    final questState = ref.watch(questNotifierProvider);

    // --- Обработка состояний загрузки и ошибки ---
    if (authState.isLoading) {
      return Center(
        // Используем акцентный цвет для индикатора
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }
    if (authState.hasError) {
      return Center(
        child: Text(
          'Ошибка загрузки данных: ${authState.error}',
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
        ),
      );
    }

    // Получаем необходимые данные
    final telegramId = authState.value?.userId ?? 'Недоступен';
    final groupId = authState.value?.groupId ?? 'Не выбрана';
    final totalScore = questState.totalScore;

    // Если данные пользователя null (хотя после инициализации это маловероятно)
    if (authState.value == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Пожалуйста, войдите в систему или выберите группу.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Аватар и Основная Идентификация
          CircleAvatar(
            radius: 60,
            // Фон: Light Surface или с низкой прозрачностью
            backgroundColor: colorScheme.onSurface.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 60,
              // Иконка: Акцентный цвет (Cyan)
              color: colorScheme.primary,
            ), // Имитация аватара
          ),
          const SizedBox(height: 16),

          // Отображаем Telegram ID
          Text(
            'ID Telegram:',
            // Второстепенный текст
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SelectableText(
            // Используем SelectableText для возможности скопировать ID
            telegramId,
            // Основной текст, но не сильно яркий
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          // Отображаем Группу
          Text(
            'Группа: $groupId',
            // Акцентный цвет для группы (Cyan)
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 30),

          // 2. Карточка с текущим Счетом (с Неоновым Свечением)
          Card(
            // Фон: Dark Surface
            color: colorScheme.surface,
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // Неоновое свечение (Secondary - Green)
                    color: colorScheme.secondary.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Набранные Баллы:',
                    // Белый текст
                    style: textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        // Цвет иконки: Neon Green
                        color: colorScheme.secondary,
                        size: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$totalScore',
                        style: textTheme.displaySmall?.copyWith(
                          // Цвет счета: Neon Green
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                          // Тень для свечения текста
                          shadows: [
                            Shadow(
                              color: colorScheme.secondary.withOpacity(0.7),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. Дополнительная (моковая) информация
          const SizedBox(height: 40),

          // Кнопка сброса группы (Имитация Выхода) с использованием _buildGradientButton из group_selection_screen
          _buildResetGroupButton(ref),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Обновленный метод, принимающий контекст для доступа к теме

  // Используем стилизацию кнопки из group_selection_screen.dart (CTA с градиентом)
  Widget _buildResetGroupButton(WidgetRef ref) {
    return Builder(
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        // Мы хотим, чтобы кнопка сброса была красной/оранжевой (цвет ошибки)
        // Но для сохранения стиля, мы сделаем ее градиентной, используя
        // ErrorColor и более темный цвет.
        final errorColor = Theme.of(context).colorScheme.error;

        // Контейнер с неоновым эффектом
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: errorColor.withOpacity(0.35),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
            // Градиент: Красный/Оранжевый к Темно-Красному
            gradient: LinearGradient(
              colors: [errorColor, errorColor.withOpacity(0.7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Material(
            color: Colors.transparent, // Важно для отображения градиента
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                ref.read(authNotifierProvider.notifier).resetGroup();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(minHeight: 55),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Иконка и текст должны быть цвета фона (темными)
                    Icon(Icons.edit, color: AppColors.background),
                    const SizedBox(width: 10),
                    Text(
                      'Поменять группу',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
