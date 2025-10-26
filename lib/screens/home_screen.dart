import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home/news_screen.dart';
import 'package:flutter_application_1/screens/home/schedule_screen.dart';
import 'package:flutter_application_1/screens/home/ideas_hub_screen.dart';
import 'package:flutter_application_1/screens/home/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Текущий индекс выбранной вкладки
  int _selectedIndex = 0;

  // Список виджетов для отображения на каждой вкладке
  static const List<Widget> _widgetOptions = <Widget>[
    NewsScreen(),
    ScheduleScreen(),
    IdeasHubScreen(),
    ProfileScreen(),
  ];

  // Метод для обработки выбора вкладки
  void _onItemTapped(int index) {
    // Используем setState для обновления _selectedIndex и перерисовки UI
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Университетский Хаб')),
      // 1. Отображение только выбранного экрана
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),

      // 2. Нижняя панель навигации
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Новости'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Идеи',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
        currentIndex: _selectedIndex, // Подсвечиваем текущую вкладку
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Вызываем метод при нажатии
      ),
    );
  }
}
