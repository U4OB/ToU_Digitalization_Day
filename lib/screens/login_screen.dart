import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/auth/auth_notifier.dart';
import 'package:flutter_application_1/data/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Моковые данные групп (в реальном приложении загружаются с бэкенда)
const List<String> mockGroups = ['CS-201', 'IS-202', 'SE-203', 'IT-204'];

class GroupSelectionScreen extends ConsumerStatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  ConsumerState<GroupSelectionScreen> createState() =>
      _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends ConsumerState<GroupSelectionScreen> {
  String? _selectedGroup;
  bool _isSaving = false;

  Future<void> _handleGroupSelection() async {
    if (_selectedGroup == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);

      // 1. Сохраняем выбранную группу в AuthNotifier (и Firestore)
      await authNotifier.setGroup(_selectedGroup!);

      // 2. Обновляем группу в QuestNotifier для синхронизации
      //uestNotifier.setGroupId(_selectedGroup!);

      if (mounted) {
        // Используем GoRouter для навигации на главный экран
        context.go(AppRoutes.quest);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Ошибка сохранения группы: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Наблюдаем за состоянием авторизации, чтобы показать, что пользователь вошел
    final authAsyncValue = ref.watch(authNotifierProvider);
    final userHasGroup = authAsyncValue.value?.groupId != null;

    // Если пользователь уже вошел и выбрал группу, перенаправляем (на случай,
    // если он вручную вернулся на этот экран)
    if (authAsyncValue.value != null &&
        userHasGroup &&
        !authAsyncValue.isLoading &&
        !_isSaving) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Используем GoRouter.go, чтобы избежать дублирования в стеке
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          context.go(AppRoutes.quest);
        }
      });
      return const Center(child: CircularProgressIndicator());
    }

    final currentGroup = authAsyncValue.value?.groupId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          "Выбор Группы",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Пожалуйста, выберите свою учебную группу для начала квеста:',
              style: TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Выпадающий список для выбора группы
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo, width: 2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGroup,
                  hint: Text(currentGroup ?? 'Выберите группу'),
                  isExpanded: true,
                  items: mockGroups.map((String group) {
                    return DropdownMenuItem<String>(
                      value: group,
                      child: Text(group, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGroup = newValue;
                    });
                  },
                ),
              ),
            ),

            if (currentGroup != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Текущая группа: $currentGroup',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 50),

            // Кнопка подтверждения
            ElevatedButton(
              onPressed: (_selectedGroup != null && !_isSaving)
                  ? _handleGroupSelection
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Text(
                      'Подтвердить и Продолжить',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
