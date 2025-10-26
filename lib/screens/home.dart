import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/widgets/news_card.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        Text(
          'Последние новости ВУЗа',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        // Использование повторно используемого виджета
        NewsCard(
          title: 'Старт сессии',
          content: 'Сессия начинается 10 января. Всем подготовиться!',
        ),
        NewsCard(
          title: 'Конкурс стартапов',
          content: 'Приглашаем всех на ежегодный конкурс инновационных идей.',
        ),
        // Добавьте еще NewsCard для демонстрации
      ],
    );
  }
}
