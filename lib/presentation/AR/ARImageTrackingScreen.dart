import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/assets/imgs/models/ar_data_models.dart';
import 'package:flutter_application_1/presentation/AR/ARService.dart';

/// Экран для AR Image Tracking
/// Использует Web AR (MindAR) для отслеживания изображений и отображения 3D объектов
class ARImageTrackingScreen extends StatefulWidget {
  /// Путь к .mind файлу с маркерами
  final String? mindFilePath;

  /// Список AR объектов для отслеживания
  final List<ArObject>? arObjects;

  const ARImageTrackingScreen({super.key, this.mindFilePath, this.arObjects});

  @override
  State<ARImageTrackingScreen> createState() => _ARImageTrackingScreenState();
}

class _ARImageTrackingScreenState extends State<ARImageTrackingScreen> {
  final ARService _arService = ARService();

  ArSessionState _currentState = ArSessionState.uninitialized;
  String? _errorMessage;
  final List<ArObjectFoundEvent> _foundObjects = [];

  StreamSubscription<ArObjectFoundEvent>? _objectFoundSubscription;
  StreamSubscription<String>? _objectLostSubscription;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription<ArSessionState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAR();
  }

  /// Инициализация AR сервиса и подписка на события
  Future<void> _initializeAR() async {
    if (!mounted) return;

    try {
      // Инициализируем сервис ПЕРЕД подпиской на события
      await _arService.initialize();

      // Подписываемся на события только после успешной инициализации
      _objectFoundSubscription = _arService.onObjectFound.listen((event) {
        if (!mounted) return;
        setState(() {
          _foundObjects.add(event);
        });
        _showObjectFoundSnackBar(event);
      });

      _objectLostSubscription = _arService.onObjectLost.listen((objectId) {
        if (!mounted) return;
        // Можно добавить обработку потери объекта
        debugPrint('AR объект потерян: $objectId');
      });

      _errorSubscription = _arService.onError.listen((error) {
        if (!mounted) return;
        setState(() {
          _errorMessage = error;
        });
        _showErrorSnackBar(error);
      });

      _stateSubscription = _arService.onStateChanged.listen((state) {
        if (!mounted) return;
        setState(() {
          _currentState = state;
        });
      });

      // Инициализируем сцену с объектами
      final objects = widget.arObjects ?? _getDefaultArObjects();
      await _arService.initializeScene(
        objects,
        mindFilePath: widget.mindFilePath ?? 'targets/targets.mind',
      );

      // Автоматически запускаем отслеживание после инициализации
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _arService.startTracking();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _currentState = ArSessionState.error;
      });
      _showErrorSnackBar('Ошибка инициализации AR: $e');
    }
  }

  /// Получение списка AR объектов по умолчанию (для примера)
  /// В реальном приложении эти данные должны приходить из API или конфигурации
  List<ArObject> _getDefaultArObjects() {
    return [
      ArObject(
        id: 'object_1',
        name: 'AR Объект 1',
        modelUrl: 'models/object1.gltf',
        targetIndex: 0,
        position: const ArPosition(0, 0, 0.1),
        scale: const ArScale(0.1, 0.1, 0.1),
        metadata: {'points': 10, 'description': 'Первый AR объект'},
      ),
      ArObject(
        id: 'object_2',
        name: 'AR Объект 2',
        modelUrl: 'models/object2.gltf',
        targetIndex: 1,
        position: const ArPosition(0, 0, 0.1),
        scale: const ArScale(0.1, 0.1, 0.1),
        metadata: {'points': 15, 'description': 'Второй AR объект'},
      ),
    ];
  }

  /// Показ уведомления об обнаружении объекта
  void _showObjectFoundSnackBar(ArObjectFoundEvent event) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎯 Объект найден: ${event.objectId}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Показ уведомления об ошибке
  void _showErrorSnackBar(String error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Ошибка: $error'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Получение текста статуса
  String _getStatusText() {
    switch (_currentState) {
      case ArSessionState.uninitialized:
        return 'Не инициализирован';
      case ArSessionState.initializing:
        return 'Инициализация...';
      case ArSessionState.ready:
        return 'Готов к работе';
      case ArSessionState.tracking:
        return 'Отслеживание активно';
      case ArSessionState.paused:
        return 'Приостановлено';
      case ArSessionState.error:
        return 'Ошибка';
    }
  }

  /// Получение цвета статуса
  Color _getStatusColor() {
    switch (_currentState) {
      case ArSessionState.uninitialized:
      case ArSessionState.initializing:
        return Colors.grey;
      case ArSessionState.ready:
        return Colors.blue;
      case ArSessionState.tracking:
        return Colors.green;
      case ArSessionState.paused:
        return Colors.orange;
      case ArSessionState.error:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // AR сцена отображается через index.html (a-scene)
          // Flutter UI накладывается поверх

          // Индикатор статуса
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildStatusCard(),
          ),

          // Список найденных объектов
          if (_foundObjects.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: _buildFoundObjectsCard(),
            ),

          // Кнопки управления
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildControlButtons(),
          ),

          // Инструкция
          if (_currentState == ArSessionState.ready ||
              _currentState == ArSessionState.tracking)
            Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              left: 16,
              right: 16,
              child: _buildInstructionCard(),
            ),
        ],
      ),
    );
  }

  /// Карточка статуса
  Widget _buildStatusCard() {
    return Card(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getStatusText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_foundObjects.isNotEmpty)
              Text(
                'Найдено: ${_foundObjects.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  /// Карточка с инструкцией
  Widget _buildInstructionCard() {
    return Card(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📷 Инструкция',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Наведите камеру на маркерное изображение для отображения 3D объекта.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ $_errorMessage',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Карточка с найденными объектами
  Widget _buildFoundObjectsCard() {
    return Card(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ Найденные объекты',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._foundObjects.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '• ${event.objectId}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Кнопки управления
  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Кнопка паузы/возобновления
        ElevatedButton.icon(
          onPressed: _currentState == ArSessionState.tracking
              ? () async {
                  await _arService.pauseTracking();
                }
              : _currentState == ArSessionState.ready ||
                    _currentState == ArSessionState.paused
              ? () async {
                  await _arService.startTracking();
                }
              : null,
          icon: Icon(
            _currentState == ArSessionState.tracking
                ? Icons.pause
                : Icons.play_arrow,
          ),
          label: Text(
            _currentState == ArSessionState.tracking ? 'Пауза' : 'Старт',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),

        // Кнопка остановки
        ElevatedButton.icon(
          onPressed: _currentState != ArSessionState.uninitialized
              ? () async {
                  await _arService.stopTracking();
                }
              : null,
          icon: const Icon(Icons.stop),
          label: const Text('Стоп'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),

        // Кнопка сброса
        ElevatedButton.icon(
          onPressed: _foundObjects.isNotEmpty
              ? () {
                  setState(() {
                    _foundObjects.clear();
                  });
                  _arService.resetFoundObjects();
                }
              : null,
          icon: const Icon(Icons.refresh),
          label: const Text('Сброс'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Отменяем подписки на события
    _objectFoundSubscription?.cancel();
    _objectLostSubscription?.cancel();
    _errorSubscription?.cancel();
    _stateSubscription?.cancel();

    // Останавливаем отслеживание, но НЕ вызываем dispose на singleton сервисе
    // так как он может использоваться другими виджетами
    _arService.stopTracking().catchError((e) {
      // Игнорируем ошибки при остановке
    });

    super.dispose();
  }
}
