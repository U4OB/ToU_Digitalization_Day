import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Импортируем контракт Use Case
import 'package:flutter_application_1/telegram/scan_qr_code_use_case.dart';
// Импортируем Interop код
import 'package:flutter_application_1/telegram/telegram_interop.dart';

// --- TwaApiService (Data Layer) ---
class TwaApiService {
  // StreamController для передачи текста из JS обратно в Dart
  final _qrTextController = StreamController<String>();

  TwaApiService() {
    // 1. При создании сервиса подписываемся на событие QR (через Interop)
    onQrTextReceived((qrData) {
      _qrTextController.add(qrData);
      closeQrScanner(); // Закрываем сканер после получения данных
    });
  }

  // 2. Метод для запуска сканера и ожидания результата
  Future<String> scanQrCode() async {
    if (!isTelegramWebAppAvailable()) {
      // Имитация для обычной веб-версии или мобильной версии Flutter
      await Future.delayed(const Duration(seconds: 1));
      return 'FAKE_QR_CODE_123';
    }

    // Запускаем нативный сканер Telegram
    showQrScanner(text: 'Наведите камеру на QR-код квеста...');

    // Ожидаем, пока StreamController получит первое событие
    // Заметка: Если пользователь нажмет "Отмена" в TWA, этот Future зависнет.
    // В реальном приложении нужно добавить обработчик 'scanQrPopupClosed'.
    final result = await _qrTextController.stream.first;
    return result;
  }

  void dispose() {
    _qrTextController.close();
  }
}

// 3. Провайдер для TwaApiService
final twaApiServiceProvider = Provider<TwaApiService>((ref) {
  final service = TwaApiService();
  // Гарантируем закрытие StreamController при удалении провайдера
  ref.onDispose(service.dispose);
  return service;
});

// --- ScanQrCodeUseCase Implementation (Domain Layer) ---

// 4. Реализация Use Case, которая использует Service (Data Layer)
class ScanQrCodeUseCaseImpl implements ScanQrCodeUseCase {
  final TwaApiService _apiService;

  ScanQrCodeUseCaseImpl(this._apiService);

  @override
  Future<String> execute() async {
    return await _apiService.scanQrCode();
  }
}

// 5. Провайдер для Use Case (для доступа из Presentation Layer)
final scanQrCodeUseCaseProvider = Provider<ScanQrCodeUseCase>((ref) {
  // Внедряем TwaApiService через его провайдер
  return ScanQrCodeUseCaseImpl(ref.read(twaApiServiceProvider));
});
