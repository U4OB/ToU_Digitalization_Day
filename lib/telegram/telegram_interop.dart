import 'dart:js_interop';

// 1. Определяем интерфейс для объекта, который передается в showScanQrPopup.
@anonymous
extension type ScanQrPopupParams._(JSObject _) implements JSObject {
  // Конструктор JS-объекта с необязательным аргументом text
  external factory ScanQrPopupParams({String? text});
}

// 2. Определяем интерфейс для Telegram.WebApp (все методы в одном месте)
@JS('Telegram.WebApp')
extension type TelegramWebApp(JSObject _) implements JSObject {
  // Стандартные методы
  external void ready();
  external void close();
  external void expand(); // Добавим для полноты, часто используется

  // Методы для QR-сканера
  external void showScanQrPopup(ScanQrPopupParams? params);
  external void closeScanQrPopup();

  // Метод для подписки на события (onEvent)
  external void onEvent(String eventType, JSFunction callback);
}

// 3. Получаем доступ к экземпляру Telegram.WebApp (переименовали для ясности)
@JS('Telegram.WebApp')
external TelegramWebApp? get telegramWebApp;

// 4. Вспомогательная функция для проверки, доступен ли WebApp
bool isTelegramWebAppAvailable() {
  return telegramWebApp != null;
}

// 5. Функции-обертки для использования в Flutter

void telegramReady() {
  telegramWebApp?.ready();
}

void telegramClose() {
  telegramWebApp?.close();
}

// 6. Реализация функции для вызова showScanQrPopup
void showQrScanner({String text = 'Отсканируйте код...'}) {
  final params = ScanQrPopupParams(text: text);
  telegramWebApp?.showScanQrPopup(params);
}

// 7. Функция для закрытия сканера
void closeQrScanner() {
  telegramWebApp?.closeScanQrPopup();
}

// lib/interop/telegram_interop.dart

// ... (остальные функции и определения)

// 8. Глобальная функция-обертка для прослушивания QR-текста
void onQrTextReceived(void Function(String) callback) {
  final jsCallback = ((JSObject event) {
    // 1. Преобразуем JSObject события в Map Dart.
    // Это позволяет использовать простой синтаксис Map[key].
    final Map<String, dynamic> eventMap =
        event.dartify() as Map<String, dynamic>;

    // 2. Извлекаем строку данных, используя знакомый синтаксис
    // Мы ожидаем структуру: { 'data': { 'data': 'QR_STRING' } }
    final Map<String, dynamic> dataObject =
        eventMap['data'] as Map<String, dynamic>;
    final String data = dataObject['data'] as String;

    // 3. Передаем полученную строку обратно в Dart-колбэк
    callback(data);
  }).toJS;

  telegramWebApp?.onEvent('qrTextReceived', jsCallback);
}
