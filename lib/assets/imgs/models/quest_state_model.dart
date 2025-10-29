import 'package:cloud_firestore/cloud_firestore.dart';

class QuestStateModel {
  final int totalScore;
  final Set<String>
  completedTasks; // Используется Set для проверки уникальности заданий

  // Идентификатор группы, который мы будем использовать для фильтрации данных
  final String groupId;

  QuestStateModel({
    required this.totalScore,
    required this.completedTasks,
    required this.groupId,
  });

  // Преобразование из JSON (Firestore)
  factory QuestStateModel.fromJson(Map<String, dynamic> json) {
    return QuestStateModel(
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      // Firestore сохраняет Set<String> как List<dynamic>
      completedTasks: Set<String>.from(json['completedTasks'] ?? []),
      groupId: json['groupId'] as String? ?? 'unknown',
    );
  }

  // Преобразование в JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'totalScore': totalScore,
      'completedTasks': completedTasks
          .toList(), // Set нельзя сохранить напрямую, конвертируем в List
      'groupId': groupId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  QuestStateModel copyWith({
    int? totalScore,
    Set<String>? completedTasks,
    String? groupId,
  }) {
    return QuestStateModel(
      totalScore: totalScore ?? this.totalScore,
      completedTasks: completedTasks ?? this.completedTasks,
      groupId: groupId ?? this.groupId,
    );
  }
}
