import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Расписание на Среду',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 16),
          // Пример элемента расписания
          _buildScheduleItem(
            time: '9:00 - 10:30',
            subject: 'Программирование на Dart/Flutter',
            location: 'Аудитория 305',
          ),
          _buildScheduleItem(
            time: '10:40 - 12:10',
            subject: 'Дискретная математика',
            location: 'Аудитория 210',
          ),
          _buildScheduleItem(
            time: '12:10 - 13:00',
            subject: 'Перерыв',
            location: 'Столовая',
            isBreak: true,
          ),
          _buildScheduleItem(
            time: '13:00 - 14:30',
            subject: 'Английский язык',
            location: 'Аудитория 101',
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem({
    required String time,
    required String subject,
    required String location,
    bool isBreak = false,
  }) {
    return Card(
      elevation: isBreak ? 0 : 3,
      color: isBreak ? Colors.grey[100] : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          isBreak ? Icons.coffee : Icons.schedule,
          color: isBreak ? Colors.brown : Colors.deepPurple,
        ),
        title: Text(
          subject,
          style: TextStyle(
            fontWeight: isBreak ? FontWeight.normal : FontWeight.w500,
            decoration: isBreak
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
        subtitle: Text('$time\n$location'),
        isThreeLine: true,
      ),
    );
  }
}
