import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/auth/auth_notifier.dart';
import 'package:flutter_application_1/data/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/styles/app_theme.dart'; // Импортируем наши стили

// Экран для выбора или ввода группы пользователем.
class GroupSelectionScreen extends ConsumerStatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  ConsumerState<GroupSelectionScreen> createState() =>
      _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends ConsumerState<GroupSelectionScreen> {
  final TextEditingController _groupController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _groupController.dispose();
    super.dispose();
  }

  void _handleSaveGroup() {
    final groupName = _groupController.text.trim();
    if (groupName.isEmpty) {
      setState(() {
        _errorMessage = 'Пожалуйста, введите название вашей группы.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    // Сохраняем группу и переходим на главный экран
    ref.read(authNotifierProvider.notifier).setGroup(groupName).then((_) {
      context.go(AppRoutes.quest);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Получаем цветовую схему из темы
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final authAsyncValue = ref.watch(authNotifierProvider);

    return Scaffold(
      // Scaffold и AppBar автоматически используют цвета из темы (AppColors.background)
      appBar: AppBar(
        title: const Text('Выбор Группы'),
        // AppBarTheme из AppThemes уже настроит titleTextStyle и iconTheme
        // Убираем жесткую установку backgroundColor и foregroundColor
      ),
      body: authAsyncValue.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.accentCyan),
        ),
        error: (err, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Ошибка авторизации: $err',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
            ),
          ),
        ),
        data: (userData) {
          if (userData == null) {
            return const Center(
              child: Text('Ошибка: Нет данных пользователя.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Заголовок (используем акцентный цвет)
                Text(
                  'Идентификация',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors
                        .accentCyan, // Прямое использование акцентного цвета
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),

                // 2. ID пользователя (второстепенный текст)
                Text(
                  'Ваш ID: ${userData.userId}',
                  style: textTheme
                      .titleSmall, // Используем стиль для второстепенного текста
                ),
                const SizedBox(height: 40),

                // 3. Заголовок для ввода группы
                Text(
                  'Введите вашу учебную группу',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // 4. Поле ввода группы
                TextField(
                  controller: _groupController,
                  // InputDecorationTheme из AppThemes уже настроит все цвета, fill, border
                  decoration: InputDecoration(
                    labelText: 'Например: IS-21, ФИТ-32',
                    // Цвет иконки будет синим из theme
                    prefixIcon: Icon(Icons.group, color: colorScheme.primary),
                    errorText: _errorMessage,
                  ),
                  style: textTheme.bodyLarge, // Цвет текста в поле - белый
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 30),

                // 5. Кнопка сохранения с градиентом (CTA)
                _buildGradientButton(
                  onPressed: _handleSaveGroup,
                  label: 'Начать квест',
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Вспомогательный метод для создания кнопки с неоновым градиентом
  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    // Используем Builder, чтобы получить доступ к Theme
    return Builder(
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;

        return Container(
          // Неоновый эффект (Glow Effect) вокруг кнопки
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentCyan.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
            // Горизонтальный Градиент (Бирюзовый к Зеленому)
            gradient: const LinearGradient(
              colors: [AppColors.accentCyan, AppColors.accentNeonGreen],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Material(
            color: Colors.transparent, // Важно для отображения градиента
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onPressed,
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
                    Icon(
                      icon,
                      color: AppColors.background,
                    ), // Текст и иконка должны быть темными
                    const SizedBox(width: 10),
                    Text(
                      label,
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
