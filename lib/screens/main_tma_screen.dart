import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Импортируем вкладки
import 'package:flutter_application_1/screens//quest_tab.dart';
import 'package:flutter_application_1/screens/quiz_tab.dart';
import 'package:flutter_application_1/screens/qr_scan_tab.dart';
import 'package:flutter_application_1/screens/score_tab.dart';

class MainTmaScreen extends ConsumerStatefulWidget {
  // Поскольку это главный экран, он не принимает параметров
  const MainTmaScreen({super.key});

  @override
  ConsumerState<MainTmaScreen> createState() => _MainTmaScreenState();
}

class _MainTmaScreenState extends ConsumerState<MainTmaScreen> {
  // Текущий индекс выбранной вкладки
  int _selectedIndex = 0;

  // Список виджетов-вкладок
  static final List<Widget> _widgetOptions = <Widget>[
    const QuestTab(), // Бывший QuestScreen, теперь как вкладка
    const QuizTab(), // ЭКРАН КВИЗА (Заглушка)
    const QrScanTab(), // ЭКРАН QR-СКАНИРОВАНИЯ (Заглушка)
    const ScoreTab(), // ЭКРАН СЧЕТА/ПРОФИЛЬ (Заглушка)
  ];

  // Список заголовков для AppBar
  static const List<String> _titles = <String>[
    'Главный Квест',
    'Прохождение Квиза',
    'Сканер QR-кодов',
    'Мой Прогресс',
  ];

  // Метод для обработки выбора вкладки
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold будет контейнером для всего TMA
    return Scaffold(
      // Динамический AppBar
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // IndexedStack сохраняет состояние всех вкладок
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

      // Нижняя панель навигации
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            activeIcon: Icon(Icons.star),
            label: 'Квест',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz),
            label: 'Квиз',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            activeIcon: Icon(Icons.qr_code_2),
            label: 'QR-сканер',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
