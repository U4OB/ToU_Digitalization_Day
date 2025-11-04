import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/quiz/quiz_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Импортируем, чтобы получить доступ к кастомным цветам (AppColors)

class QuizTab extends ConsumerWidget {
  const QuizTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем цветовую схему из темы для стилизации
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 1. Читаем Notifier для доступа к его методам
    final notifier = ref.read(quizNotifierProvider.notifier);

    // 2. Отслеживаем состояние загрузки/вопросов
    final state = ref.watch(quizNotifierProvider);

    // 💡 ИСПРАВЛЕНИЕ: Отложенный вызов loadQuestions().
    if (state.questions.isEmpty &&
        !state.loadingState.isLoading &&
        !state.loadingState.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.exists(quizNotifierProvider) &&
            ref.read(quizNotifierProvider).questions.isEmpty) {
          notifier.loadQuestions();
        }
      });
    }

    // --- Отображение состояний ---

    // Состояние загрузки
    if (state.loadingState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Стилизованный CircularProgressIndicator (использует primary: Cyan)
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 20),
            // Стилизованный текст
            Text(
              'Загрузка вопросов...',
              style: textTheme.bodyLarge, // Белый текст
            ),
          ],
        ),
      );
    }

    // Состояние ошибки
    if (state.loadingState.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Ошибка загрузки: ${state.loadingState.error}',
            // Используем цвет ошибки из темы
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Состояние завершения квиза (или если вопросов нет)
    if (state.isCompleted || state.currentQuestion == null) {
      return _buildCompletionScreen(context, state, notifier);
    }

    // --- Активный Квиз ---
    final currentQuestion = state.currentQuestion!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Прогресс
            _buildProgress(context, state),
            const SizedBox(height: 30),

            // Текст вопроса
            Text(
              currentQuestion.text,
              // Используем заголовок секции, цвет - белый
              style: textTheme.titleLarge?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Варианты ответов
            ...currentQuestion.options.map((option) {
              return _buildOptionButton(
                context,
                option: option,
                isSelected: state.selectedAnswer == option,
                onTap: () => notifier.selectAnswer(option),
              );
            }),

            const SizedBox(height: 40),

            // Кнопка "Ответить/Завершить"
            // Удаляем жестко заданный стиль, чтобы использовался ElevatedButtonTheme
            ElevatedButton(
              // Кнопка активна только если выбран ответ
              onPressed: state.selectedAnswer != null
                  ? notifier.submitAnswerAndAdvance
                  : null,
              // Удаляем styleFrom, полагаясь на AppThemes для неонового стиля
              child: Text(
                state.isLastQuestion ? 'Завершить Квиз' : 'Ответить и Далее',
                style: textTheme.labelLarge?.copyWith(
                  // Текст кнопки должен быть темным (background)
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Вспомогательные методы UI ---

  // Виджет для отображения прогресса
  Widget _buildProgress(BuildContext context, QuizState state) {
    if (state.questions.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final total = state.questions.length;
    final current = state.currentQuestionIndex + 1;
    final progress = current / total;

    return Column(
      children: [
        Text(
          'Вопрос $current из $total',
          // Используем второстепенный текст из темы
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          // Цвет фона: светлый оттенок поверхности
          backgroundColor: colorScheme.surface.withOpacity(0.7),
          // Цвет прогресса: акцентный цвет (Cyan)
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  // Виджет для кнопки-варианта ответа
  Widget _buildOptionButton(
    BuildContext context, {
    required String option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      // Используем InkWell и Container для создания кастомного вида,
      // напоминающего OutlinedButton, но стилизованного под темную тему.
      child: Material(
        color: isSelected
            ? colorScheme.primary.withOpacity(
                0.15,
              ) // Выбранный: легкий неоновый фон
            : colorScheme.surface, // Невыбранный: фон карточки
        elevation: isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            // Граница: яркая, если выбрана, тусклая, если не выбрана
            color: isSelected
                ? colorScheme.primary
                : colorScheme.surface.withOpacity(0.5),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              option,
              textAlign: TextAlign.left,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                // Текст: акцентный, если выбран, белый, если не выбран
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Экран завершения квиза
  Widget _buildCompletionScreen(
    BuildContext context,
    QuizState state,
    QuizNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxScore = state.questions.length * QuizNotifier.pointsPerQuestion;

    // Цвет успеха - Neon Green (secondary accent)
    final successColor = colorScheme.secondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка успеха
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: successColor, // Neon Green
            ),
            const SizedBox(height: 20),
            // Текст "Квиз Завершен"
            Text(
              'Квиз Завершен!',
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 26,
                color: successColor, // Neon Green
              ),
            ),
            const SizedBox(height: 10),
            // Счет
            Text(
              'Вы набрали ${state.score} из $maxScore возможных баллов.',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium, // Белый текст
            ),
            const SizedBox(height: 40),

            // Кнопка "Пройти заново" (CTA)
            ElevatedButton.icon(
              onPressed: notifier.restartQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Пройти заново'),
              // Убираем styleFrom, чтобы использовать ElevatedButtonTheme
              // (Неоновый градиент Cyan/Green)
            ),
          ],
        ),
      ),
    );
  }
}
