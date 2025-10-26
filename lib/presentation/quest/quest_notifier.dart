import 'package:flutter_riverpod/flutter_riverpod.dart';

// Состояние квеста: хранит счет, найденные QR/AR
class QuestState {
  final int score;
  // Используем Set<String> для хранения уникальных ID выполненных заданий
  final Set<String> completedTasks;

  QuestState({this.score = 0, this.completedTasks = const {}});

  QuestState copyWith({int? score, Set<String>? completedTasks}) {
    return QuestState(
      score: score ?? this.score,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }
}

// StateNotifier (не Async, так как мы управляем простым состоянием)
class QuestNotifier extends StateNotifier<QuestState> {
  QuestNotifier() : super(QuestState());

  // Метод для добавления очков за выполненное задание
  bool addScore(int points, String taskId) {
    if (state.completedTasks.contains(taskId)) {
      print('Задание $taskId уже выполнено. Счет не изменен.');
      return false; // Задание уже выполнено
    }

    // Добавляем ID в список выполненных
    final newCompleted = {...state.completedTasks, taskId};
    final newScore = state.score + points;

    state = state.copyWith(score: newScore, completedTasks: newCompleted);
    print('Добавлено $points очков. Общий счет: $newScore');
    return true; // Задание выполнено успешно
  }

  // Сброс квеста
  void resetQuest() {
    state = QuestState();
  }
}

final questNotifierProvider = StateNotifierProvider<QuestNotifier, QuestState>(
  (ref) => QuestNotifier(),
);
