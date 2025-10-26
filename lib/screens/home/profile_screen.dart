import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            child: Icon(Icons.person, size: 80), // Имитация аватара
          ),
          const SizedBox(height: 16),
          const Text(
            'Иванов Иван',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Студент, Группа: КБ-401',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 30),

          // Карточка с основной информацией
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _buildProfileInfo(Icons.email, 'Email', 'ivanov@uni.kz'),
                const Divider(),
                _buildProfileInfo(
                  Icons.school,
                  'ВУЗ',
                  'Казахский Национальный Университет',
                ),
                const Divider(),
                _buildProfileInfo(
                  Icons.book,
                  'Специальность',
                  'Информационная безопасность',
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Кнопка выхода (Logout)
          ElevatedButton.icon(
            onPressed: () {
              // В будущем здесь будет логика выхода через Riverpod
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Выход из системы... (логика будет добавлена)'),
                ),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(value, style: const TextStyle(color: Colors.black54)),
    );
  }
}
