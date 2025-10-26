import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/presentation/quest/quest_notifier.dart';

// 🔑 Теперь это вкладка, а не отдельный экран
class QuestTab extends ConsumerWidget {
  const QuestTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 Читаем состояние квеста
    final questState = ref.watch(questNotifierProvider);

    // Удаляем Scaffold и AppBar, так как они в MainTmaScreen
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 💡 Отображение реального счета
            const Icon(Icons.star, size: 60, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              'Ваш текущий счет:',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            Text(
              '${questState.score} баллов',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 60),

            const Text(
              'Используйте нижнее меню для перехода к заданиям:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Заглушка, напоминающая о наличии заданий
            ElevatedButton.icon(
              onPressed: () {
                // В будущем здесь будет навигация на другую вкладку или модальное окно с инструкциями
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Переключитесь на вкладки "Квиз" или "QR-сканер" для начала.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_downward),
              label: const Text('Начать Квест'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
