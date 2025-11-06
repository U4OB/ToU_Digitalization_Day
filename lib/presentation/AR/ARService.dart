import 'dart:async';
import 'package:flutter_application_1/assets/imgs/models/ar_data_models.dart';
import 'package:flutter_application_1/presentation/AR/ar_interop_manager.dart';

/// Сервис для управления AR состоянием и логикой
/// Предоставляет высокоуровневый API для работы с AR
class ARService {
  static final ARService _instance = ARService._internal();
  factory ARService() => _instance;
  ARService._internal();

  final ArInteropManager _interopManager = ArInteropManager();

  /// Текущее состояние AR сессии
  ArSessionState _currentState = ArSessionState.uninitialized;
  ArSessionState get currentState => _currentState;

  /// Stream для событий обнаружения объектов
  StreamController<ArObjectFoundEvent> _objectFoundController =
      StreamController<ArObjectFoundEvent>.broadcast();
  Stream<ArObjectFoundEvent> get onObjectFound => _objectFoundController.stream;

  /// Stream для событий потери отслеживания
  StreamController<String> _objectLostController =
      StreamController<String>.broadcast();
  Stream<String> get onObjectLost => _objectLostController.stream;

  /// Stream для ошибок
  StreamController<String> _errorController =
      StreamController<String>.broadcast();
  Stream<String> get onError => _errorController.stream;

  /// Stream для изменений состояния
  StreamController<ArSessionState> _stateController =
      StreamController<ArSessionState>.broadcast();
  Stream<ArSessionState> get onStateChanged => _stateController.stream;

  /// Список найденных объектов (для предотвращения дублирования)
  final Set<String> _foundObjects = {};

  bool _isInitialized = false;

  /// Инициализация сервиса
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Пересоздаем StreamController'ы, если они были закрыты
    if (_objectFoundController.isClosed) {
      _objectFoundController = StreamController<ArObjectFoundEvent>.broadcast();
    }
    if (_objectLostController.isClosed) {
      _objectLostController = StreamController<String>.broadcast();
    }
    if (_errorController.isClosed) {
      _errorController = StreamController<String>.broadcast();
    }
    if (_stateController.isClosed) {
      _stateController = StreamController<ArSessionState>.broadcast();
    }

    // Настраиваем callback'и
    _interopManager.onObjectFound = (event) {
      // Предотвращаем дублирование событий
      if (!_foundObjects.contains(event.objectId) &&
          !_objectFoundController.isClosed) {
        _foundObjects.add(event.objectId);
        _objectFoundController.add(event);
      }
    };

    _interopManager.onObjectLost = (objectId) {
      if (!_objectLostController.isClosed) {
        _objectLostController.add(objectId);
      }
    };

    _interopManager.onError = (error) {
      if (!_errorController.isClosed) {
        _errorController.add(error);
      }
    };

    _interopManager.onStateChanged = (state) {
      _currentState = state;
      if (!_stateController.isClosed) {
        _stateController.add(state);
      }
    };

    _interopManager.initialize();
    _isInitialized = true;
  }

  /// Инициализация AR сцены с объектами
  ///
  /// [objects] - список AR объектов для размещения
  /// [mindFilePath] - путь к .mind файлу с маркерами
  Future<void> initializeScene(
    List<ArObject> objects, {
    String mindFilePath = 'targets/targets.mind',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Проверяем доступность камеры (но не запрашиваем разрешение здесь,
    // так как MindAR сам запросит его при start())
    final hasCamera = await _interopManager.checkCameraAvailability();
    if (!hasCamera) {
      throw Exception('Камера недоступна на этом устройстве');
    }

    // НЕ запрашиваем разрешение здесь - MindAR сделает это при start()
    // Это позволяет избежать двойного запроса разрешения

    // Инициализируем сцену
    await _interopManager.initializeArScene(
      objects,
      mindFilePath: mindFilePath,
    );
  }

  /// Запуск отслеживания
  Future<void> startTracking() async {
    if (_currentState == ArSessionState.tracking) {
      return; // Уже отслеживаем
    }

    await _interopManager.startTracking();
  }

  /// Остановка отслеживания
  Future<void> stopTracking() async {
    await _interopManager.stopTracking();
  }

  /// Пауза отслеживания
  Future<void> pauseTracking() async {
    await _interopManager.pauseTracking();
  }

  /// Сброс списка найденных объектов
  void resetFoundObjects() {
    _foundObjects.clear();
  }

  /// Проверка, был ли объект уже найден
  bool isObjectFound(String objectId) {
    return _foundObjects.contains(objectId);
  }

  /// Очистка ресурсов
  /// ВАЖНО: Не закрываем StreamController'ы, так как сервис - singleton
  /// и может использоваться несколькими виджетами
  void dispose() {
    // Не закрываем StreamController'ы, чтобы не ломать другие подписки
    // Вместо этого просто очищаем состояние
    _interopManager.dispose();
    _foundObjects.clear();
    _isInitialized = false;

    // Сбрасываем callback'и
    _interopManager.onObjectFound = null;
    _interopManager.onObjectLost = null;
    _interopManager.onError = null;
    _interopManager.onStateChanged = null;
  }

  /// Полная очистка (использовать только при полном завершении приложения)
  void disposeCompletely() {
    if (!_objectFoundController.isClosed) {
      _objectFoundController.close();
    }
    if (!_objectLostController.isClosed) {
      _objectLostController.close();
    }
    if (!_errorController.isClosed) {
      _errorController.close();
    }
    if (!_stateController.isClosed) {
      _stateController.close();
    }
    _interopManager.dispose();
    _foundObjects.clear();
    _isInitialized = false;
  }
}
