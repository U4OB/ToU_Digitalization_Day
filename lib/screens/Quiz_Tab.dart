import 'package:flutter/material.dart';

class QuizTab extends StatelessWidget {
  const QuizTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'ЭКРАН КВИЗА. Начните отвечать на вопросы!',
        style: TextStyle(fontSize: 18, color: Colors.blueGrey),
      ),
    );
  }
}
