import 'package:flutter/material.dart';

class IdeasHubScreen extends StatelessWidget {
  const IdeasHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_outline, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              'Хаб Идей',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Предложите идею по улучшению кампуса, учебного процесса или студенческой жизни.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // В будущем здесь будет навигация на экран добавления идеи
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Открыта форма для новой идеи!'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Добавить идею'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
