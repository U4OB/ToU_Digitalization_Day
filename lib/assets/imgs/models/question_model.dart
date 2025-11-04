// Модель данных для одного вопроса
class Question {
  final String id;
  final String text;
  final List<String> options; // Варианты ответа
  final String
  correctAnswer; // Правильный ответ (строковое совпадение с одним из options)

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswer,
  });

  // Метод для создания экземпляра Question из JSON-объекта,
  // полученного с "бэкенда"
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      // В реальном приложении нужно убедиться, что список опций не пуст
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as String,
    );
  }

  // Метод для проверки ответа
  bool isCorrect(String selectedAnswer) {
    return selectedAnswer == correctAnswer;
  }
}
