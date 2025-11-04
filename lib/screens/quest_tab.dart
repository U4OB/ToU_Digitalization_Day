import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/presentation/quest/quest_notifier.dart';
// НОВЫЕ ИМПОРТЫ для навигации по заданиям
import 'package:flutter_application_1/screens/quiz_tab.dart';
import 'package:flutter_application_1/screens/qr_scan_tab.dart';

// --- Данные для Roadmap ---

// Моковая структура заданий (для демонстрации Roadmap)
class QuestTask {
  final String id;
  final String title;
  final String description;
  final int maxScore;
  final IconData icon;

  const QuestTask({
    required this.id,
    required this.title,
    required this.description,
    required this.maxScore,
    required this.icon,
  });
}

// Список всех заданий квеста
const List<QuestTask> questRoadmap = [
  QuestTask(
    id: 'MAIN_QUIZ_001',
    title: 'Quiz: Основы IT',
    description:
        'Пройди тест на знание ключевых терминов и концепций цифровизации.',
    maxScore: 50, // Предположим, что в квизе 5 вопросов по 10 баллов
    icon: Icons.quiz,
  ),
  QuestTask(
    id: 'QR_SCAN_LAB_002',
    title: 'QR-Квест: Лаборатории',
    description:
        'Найди и отсканируй QR-коды в IT-лабораториях, чтобы получить секретный код.',
    maxScore: 30,
    icon: Icons.qr_code_scanner,
  ),
  QuestTask(
    id: 'AR_TASK_003',
    title: 'AR-Задача: Секретный Объект',
    description:
        'Используй AR-сканер для поиска виртуального объекта на территории ВУЗа. (Недоступно)',
    maxScore: 20,
    icon: Icons.camera_alt,
  ),
];

// --- Вспомогательный Виджет для Элемента Roadmap (СДЕЛАНО КЛИКАБЕЛЬНЫМ) ---

class _QuestRoadmapItem extends ConsumerWidget {
  final QuestTask task;

  const _QuestRoadmapItem({required this.task});

  // Логика навигации на основе ID задания
  void _navigateToTaskScreen(BuildContext context) {
    Widget? targetScreen;
    String screenTitle;

    // В зависимости от ID задания, определяем, куда навигировать
    switch (task.id) {
      case 'MAIN_QUIZ_001':
        targetScreen = const QuizTab();
        screenTitle = 'Прохождение Квиза';
        break;
      case 'QR_SCAN_LAB_002':
        targetScreen = const QrScanTab();
        screenTitle = 'Сканер QR-кодов';
        break;
      case 'AR_TASK_003':
        // AR-задание пока недоступно, выводим заглушку
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AR-задание пока находится в разработке!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      default:
        return;
    }

    if (targetScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(screenTitle)),
            body: targetScreen,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final questState = ref.watch(questNotifierProvider);
    // Проверяем, выполнено ли задание
    final isCompleted = questState.completedTasks.contains(task.id);

    // НОВОЕ: Оборачиваем Card в InkWell для кликабельности
    return InkWell(
      onTap: () => _navigateToTaskScreen(context), // Вызываем навигацию
      borderRadius: BorderRadius.circular(15),
      child: Card(
        // Используем transparent, т.к. InkWell уже предоставляет ripple эффект
        color: colorScheme.surface,
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            // Граница: Secondary (Neon Green) для завершенных, Primary (Cyan) для активных
            color: isCompleted ? colorScheme.secondary : colorScheme.primary,
            width: isCompleted ? 2.5 : 1,
          ),
        ),
        // Убираем Padding из Card, чтобы добавить его внутрь для лучшего управления InkWell
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                task.icon,
                size: 30,
                // Цвет иконки: Neon Green, если завершено, Cyan, если активно
                color: isCompleted
                    ? colorScheme.secondary
                    : colorScheme.primary,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: textTheme.bodyLarge?.copyWith(
                        // Текст: тусклый, если завершен, яркий белый, если активен
                        color: isCompleted
                            ? colorScheme.onSurface.withOpacity(0.7)
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        // Цвет зачеркивания: Neon Green
                        decorationColor: colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      // Используем bodySmall для описания
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Отображение баллов или статуса
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isCompleted ? '✅' : '',
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      // Цвет баллов: Secondary (Green) для завершенных, Primary (Cyan) для активных
                      color: isCompleted
                          ? colorScheme.secondary
                          : colorScheme.primary,
                    ),
                  ),
                  if (isCompleted)
                    Text(
                      'Завершено',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.secondary, // Neon Green
                      ),
                    ),
                  // НОВОЕ: Показываем баллы, если не завершено
                  // if (!isCompleted)
                  //   Text(
                  //     '+${task.maxScore}',
                  //     style: textTheme.titleMedium?.copyWith(
                  //       color: colorScheme.primary,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Основной Виджет QuestTab (без изменений) ---

class QuestTab extends ConsumerWidget {
  const QuestTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final questState = ref.watch(questNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Приветствие и Описание Дня
          Text(
            'Сегодня День Цифровизации!',
            // Используем заголовок секции с акцентным цветом
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.primary, // Cyan
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Прими участие в интерактивном квесте, чтобы проверить свои знания в IT и исследовать цифровые ресурсы нашего ВУЗа. Твоя цель — набрать максимум баллов!',
            // Используем основной текст
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 30),

          // 2. Карточка Текущего Счета
          Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 30,
                ),
                // Убираем градиент, используем Surface с неоновым свечением
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      // Неоновое свечение от основного цвета
                      color: colorScheme.primary.withOpacity(0.35),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Ваш Текущий Счет',
                      // Второстепенный текст, цвет из темы
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${questState.totalScore} БАЛЛОВ',
                      style: textTheme.headlineLarge?.copyWith(
                        // Яркий акцентный цвет для счета (Cyan)
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        // Текстовая тень для эффекта свечения
                        shadows: [
                          Shadow(
                            color: colorScheme.primary.withOpacity(0.7),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // 3. Roadmap (Дорожная Карта Квеста)
          Text(
            'Дорожная Карта Квеста:',
            // Используем titleLarge для основного заголовка (Белый)
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 20),

          // Список заданий
          ...questRoadmap.map((task) => _QuestRoadmapItem(task: task)),

          const SizedBox(height: 20),
          Center(
            child: Text(
              'Нажмите на задание, чтобы начать его выполнение!',
              // Используем bodySmall с пониженной прозрачностью
              style: textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: colorScheme.onBackground.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
