import 'package:flutter_application_1/assets/imgs/models/question_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Контракт (Интерфейс) Репозитория ---
abstract class QuizRepository {
  // Получает список вопросов для квиза. В будущем здесь могут быть параметры
  // типа universityId или questStage.
  Future<List<Question>> getQuestions();
}

// --- Реализация Репозитория с Заглушкой ---
class MockQuizRepository implements QuizRepository {
  // Моковые данные, имитирующие ответ бэкенда
  final List<Map<String, dynamic>> _mockData = [
    {
      'id': 'q1',
      'text': 'Какова столица Казахстана?',
      'options': ['Алматы', 'Шымкент', 'Астана', 'Караганда'],
      'correctAnswer': 'Астана',
    },
    {
      'id': 'q2',
      'text': 'Кто является автором эпоса "Кобланды батыр"?',
      'options': [
        'Абай Кунанбаев',
        'Жамбыл Жабаев',
        'Народный эпос',
        'Мухтар Ауэзов',
      ],
      'correctAnswer': 'Народный эпос',
    },
    {
      'id': 'q3',
      'text': 'Какое крупнейшее озеро в Казахстане (частично)?',
      'options': ['Балхаш', 'Аральское море', 'Каспийское море', 'Зайсан'],
      'correctAnswer': 'Каспийское море',
    },
  ];

  @override
  Future<List<Question>> getQuestions() async {
    // Имитация сетевой задержки (например, 2 секунды)
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Преобразование моковых данных в список моделей Question
      return _mockData.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      // 💡 ВАЖНОЕ ИСПРАВЛЕНИЕ: Логируем и перебрасываем ошибку, чтобы она
      // была поймана в Notifier и вывела UI из состояния "загрузки".
      print('ОШИБКА В РЕПОЗИТОРИИ: Не удалось получить/распарсить вопросы. $e');
      rethrow;
    }
  }
}

// --- Провайдеры ---

// Провайдер для QuizRepository
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  // В реальном проекте здесь будет QuizRepositoryImpl(httpClient: ...)
  return MockQuizRepository();
});
