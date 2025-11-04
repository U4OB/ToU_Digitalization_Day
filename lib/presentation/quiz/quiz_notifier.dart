import 'package:flutter_application_1/presentation/quiz/quiz_repository.dart';
import 'package:flutter_application_1/assets/imgs/models/question_model.dart';
import 'package:flutter_application_1/presentation/quest/quest_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Состояние Квиза ---

class QuizState {
  // Список всех вопросов
  final List<Question> questions;
  // Индекс текущего вопроса, который отображается
  final int currentQuestionIndex;
  // Ответ, выбранный пользователем для текущего вопроса
  final String? selectedAnswer;
  // Промежуточный счет за правильные ответы
  final int score;
  // Флаг, указывающий, завершен ли квиз
  final bool isCompleted;

  // Используем AsyncValue для удобного управления состоянием загрузки/ошибки
  final AsyncValue<void> loadingState;

  QuizState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswer,
    this.score = 0,
    this.isCompleted = false,
    this.loadingState = const AsyncValue.data(null),
  });

  // Геттер, который возвращает текущий вопрос
  Question? get currentQuestion =>
      questions.isEmpty ? null : questions[currentQuestionIndex];

  // Геттер, который проверяет, последний ли это вопрос
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  // Метод для копирования состояния
  QuizState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    String? selectedAnswer,
    int? score,
    bool? isCompleted,
    AsyncValue<void>? loadingState,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswer:
          selectedAnswer, // При переходе на новый вопрос, сбрасываем ответ
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
      loadingState: loadingState ?? this.loadingState,
    );
  }
}

// --- Notifier Квиза ---

class QuizNotifier extends StateNotifier<QuizState> {
  final QuizRepository _repository;
  final QuestNotifier _questNotifier;

  // Количество очков за правильный ответ в квизе
  static const int pointsPerQuestion = 10;
  // Уникальный ID задания (для QuestNotifier)
  static const String quizTaskId = 'MAIN_QUIZ_001';

  QuizNotifier(this._repository, this._questNotifier) : super(QuizState()) {
    // 💡 ДЕБАГ-ЛОГ 1: Notifier создан
    print('✅ DEBUG 1: QuizNotifier успешно создан.');
  }

  // 1. Загрузка вопросов
  Future<void> loadQuestions() async {
    // 💡 ДЕБАГ-ЛОГ 2: Вызов loadQuestions
    print('✅ DEBUG 2: Начат вызов loadQuestions().');

    // Если вопросы уже загружены, просто сбросим состояние, если квиз завершен
    if (state.questions.isNotEmpty && !state.isCompleted) return;

    state = state.copyWith(loadingState: const AsyncValue.loading());

    try {
      final questions = await _repository.getQuestions();

      // 💡 ДЕБАГ-ЛОГ 3: Вопросы успешно получены
      print(
        '✅ DEBUG 3: Вопросы успешно получены из репозитория. Всего: ${questions.length}',
      );

      state = state.copyWith(
        questions: questions,
        currentQuestionIndex: 0,
        score: 0,
        isCompleted: false,
        loadingState: const AsyncValue.data(null),
        selectedAnswer: null,
      );
    } catch (e, st) {
      // Здесь ловится ошибка из Репозитория и переводит UI в состояние ошибки
      state = state.copyWith(loadingState: AsyncValue.error(e, st));
      // 💡 ДЕБАГ-ЛОГ 4: Ошибка загрузки
      print('❌ DEBUG 4: Ошибка загрузки вопросов: $e. StackTrace: $st');
    }
  }

  // 2. Выбор ответа
  void selectAnswer(String answer) {
    state = state.copyWith(selectedAnswer: answer);
  }

  // 3. Обработка перехода к следующему вопросу (или завершение квиза)
  Future<void> submitAnswerAndAdvance() async {
    final currentQuestion = state.currentQuestion;
    final selectedAnswer = state.selectedAnswer;

    if (currentQuestion == null || selectedAnswer == null) {
      // Пользователь должен выбрать ответ
      return;
    }

    int newScore = state.score;

    // Проверяем правильность ответа и обновляем счет
    if (currentQuestion.isCorrect(selectedAnswer)) {
      newScore += pointsPerQuestion;
    }

    // Если это последний вопрос
    if (state.isLastQuestion) {
      state = state.copyWith(
        score: newScore,
        isCompleted: true,
        currentQuestionIndex:
            state.currentQuestionIndex + 1, // Для выхода из границ
      );
      // Начисляем финальный счет за весь квиз
      _finalizeQuizScore(newScore);
    } else {
      // Переход к следующему вопросу
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        score: newScore,
        selectedAnswer: null, // Сброс выбранного ответа для нового вопроса
      );
    }
  }

  // 4. Финализация и начисление баллов в общий квест
  void _finalizeQuizScore(int finalQuizScore) {
    if (finalQuizScore > 0) {
      // Мы используем quizTaskId для проверки, был ли квиз уже пройден
      // Начисляем баллы только если задание еще не выполнено.
      final success = _questNotifier.addScore(finalQuizScore, quizTaskId);

      if (success) {
        print(
          'УСПЕХ: Квиз завершен. Начислено $finalQuizScore баллов в общий счет.',
        );
      } else {
        print(
          'Квиз уже был пройден. Результат $finalQuizScore, но баллы не добавлены.',
        );
      }
    }
  }

  // 5. Перезапуск квиза
  void restartQuiz() {
    loadQuestions(); // Перезагружаем вопросы и сбрасываем состояние
  }
}

// --- Провайдеры ---

final quizNotifierProvider = StateNotifierProvider<QuizNotifier, QuizState>((
  ref,
) {
  // 1. Читаем репозиторий (Data Layer)
  final repository = ref.watch(quizRepositoryProvider);
  // 2. Читаем QuestNotifier (для начисления финальных баллов)
  // 💡 Если этот ref.watch(questNotifierProvider.notifier) падает синхронно,
  // то QuizNotifier не будет создан, и мы не увидим даже "DEBUG 1".
  final questNotifier = ref.watch(questNotifierProvider.notifier);

  return QuizNotifier(repository, questNotifier);
});
