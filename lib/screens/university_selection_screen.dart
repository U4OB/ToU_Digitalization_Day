import 'package:flutter/material.dart';
import 'login_screen.dart';

class UniversitySelectionScreen extends StatelessWidget {
  const UniversitySelectionScreen({super.key});

  final List<String> universities = const [
    'Казахский Национальный Университет',
    'Назарбаев Университет',
    'Евразийский Национальный Университет',
    'Алматинский Технологический Университет',
    'Карагандинский Государственный Университет',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text("Выберите ВУЗ"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: universities.length,
        itemBuilder: (context, index) {
          final universityName = universities[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.school, color: Colors.yellow),
              title: Text(
                universityName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text('Нажмите, чтобы выбрать'),
              onTap: () {
                _navigateToLogin(context);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToLogin(context);
        },
        backgroundColor: Colors.yellow,
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

void _navigateToLogin(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => GroupSelectionScreen()),
  );
}
