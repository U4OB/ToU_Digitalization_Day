import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:convert';
import 'package:flutter_application_1/assets/imgs/models/ar_data_models.dart';

/// Менеджер для взаимодействия между Flutter и JavaScript AR модулем
/// Обеспечивает двустороннюю связь для управления AR сценой
class ArInteropManager {
  static final ArInteropManager _instance = ArInteropManager._internal();
  factory ArInteropManager() => _instance;
  ArInteropManager._internal();

  /// Callback для событий обнаружения объектов
  Function(ArObjectFoundEvent)? onObjectFound;

  /// Callback для событий потери отслеживания
  Function(String objectId)? onObjectLost;

  /// Callback для ошибок AR
  Function(String error)? onError;

  /// Callback для изменения состояния сессии
  Function(ArSessionState state)? onStateChanged;

  bool _isInitialized = false;

  /// Инициализация менеджера и регистрация глобальных callback функций
  void initialize() {
    if (_isInitialized) return;

    // Регистрируем глобальную функцию для обратного вызова из JavaScript
    js.context['arObjectFound'] = (String objectId) {
      final event = ArObjectFoundEvent(objectId: objectId);
      onObjectFound?.call(event);
    };

    js.context['arObjectLost'] = (String objectId) {
      onObjectLost?.call(objectId);
    };

    js.context['arError'] = (String error) {
      onError?.call(error);
    };

    js.context['arStateChanged'] = (String state) {
      final arState = _parseState(state);
      onStateChanged?.call(arState);
    };

    _isInitialized = true;
  }

  /// Парсинг строкового состояния в enum
  ArSessionState _parseState(String state) {
    switch (state.toLowerCase()) {
      case 'uninitialized':
        return ArSessionState.uninitialized;
      case 'initializing':
        return ArSessionState.initializing;
      case 'ready':
        return ArSessionState.ready;
      case 'tracking':
        return ArSessionState.tracking;
      case 'paused':
        return ArSessionState.paused;
      case 'error':
        return ArSessionState.error;
      default:
        return ArSessionState.uninitialized;
    }
  }

  /// Ожидание загрузки JavaScript функции
  Future<void> _waitForJsFunction(
    String functionName, {
    int maxAttempts = 30,
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      final jsFunction = js.context[functionName];
      if (jsFunction != null) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    throw Exception(
      'JavaScript функция $functionName не загружена после ${maxAttempts} попыток. Проверьте загрузку скриптов.',
    );
  }

  /// Инициализация AR сцены с переданными объектами
  ///
  /// [objects] - список AR объектов для размещения на сцене
  /// [mindFilePath] - путь к .mind файлу с маркерами (по умолчанию targets/targets.mind)
  Future<void> initializeArScene(
    List<ArObject> objects, {
    String mindFilePath = 'targets/targets.mind',
  }) async {
    if (!_isInitialized) {
      initialize();
    }

    try {
      // Ждем загрузки JavaScript функции (скрипты могут загружаться асинхронно)
      await _waitForJsFunction('initializeArScene');

      // Преобразуем объекты в JSON
      final objectsJson = jsonEncode(objects.map((o) => o.toJson()).toList());

      // Получаем функцию после ожидания
      final jsFunction = js.context['initializeArScene'];
      if (jsFunction == null) {
        throw Exception(
          'JavaScript функция initializeArScene не найдена после ожидания.',
        );
      }

      // Вызываем JavaScript функцию инициализации через callMethod
      // Это гарантирует правильную обработку Promise
      final result = js.context.callMethod('initializeArScene', [
        objectsJson,
        mindFilePath,
      ]);

      // Проверяем, что результат не null
      if (result == null) {
        throw Exception(
          'Функция initializeArScene вернула null. Проверьте консоль браузера для деталей.',
        );
      }

      // Преобразуем результат в js.JsObject для promiseToFuture
      // callMethod возвращает dynamic, нужно привести к правильному типу
      final jsPromise = result is js.JsObject
          ? result
          : js.JsObject.jsify(result);

      // Преобразуем Promise в Future для правильной обработки async функции
      await js_util.promiseToFuture(jsPromise);
    } catch (e) {
      onError?.call('Ошибка инициализации AR сцены: $e');
      rethrow;
    }
  }

  /// Запуск AR отслеживания
  Future<void> startTracking() async {
    try {
      final jsFunction = js.context['startArTracking'];
      if (jsFunction != null) {
        jsFunction.apply([]);
      }
    } catch (e) {
      onError?.call('Ошибка запуска отслеживания: $e');
    }
  }

  /// Остановка AR отслеживания
  Future<void> stopTracking() async {
    try {
      final jsFunction = js.context['stopArTracking'];
      if (jsFunction != null) {
        jsFunction.apply([]);
      }
    } catch (e) {
      onError?.call('Ошибка остановки отслеживания: $e');
    }
  }

  /// Пауза AR отслеживания
  Future<void> pauseTracking() async {
    try {
      final jsFunction = js.context['pauseArTracking'];
      if (jsFunction != null) {
        jsFunction.apply([]);
      }
    } catch (e) {
      onError?.call('Ошибка паузы отслеживания: $e');
    }
  }

  /// Проверка доступности камеры
  Future<bool> checkCameraAvailability() async {
    try {
      if (html.window.navigator.mediaDevices != null) {
        final devices = await html.window.navigator.mediaDevices!
            .enumerateDevices();
        return devices.any((device) => device.kind == 'videoinput');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Запрос разрешения на использование камеры
  Future<bool> requestCameraPermission() async {
    try {
      if (html.window.navigator.mediaDevices != null) {
        final stream = await html.window.navigator.mediaDevices!.getUserMedia({
          'video': true,
        });
        // Закрываем поток, так как MindAR сам управляет камерой
        stream.getTracks().forEach((track) => track.stop());
        return true;
      }
      return false;
    } catch (e) {
      onError?.call('Ошибка доступа к камере: $e');
      return false;
    }
  }

  /// Очистка ресурсов
  void dispose() {
    onObjectFound = null;
    onObjectLost = null;
    onError = null;
    onStateChanged = null;
    _isInitialized = false;
  }
}
