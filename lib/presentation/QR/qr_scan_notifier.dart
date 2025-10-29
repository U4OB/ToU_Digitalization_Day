import 'package:flutter_application_1/telegram/scan_qr_code_use_case.dart';
import 'package:flutter_application_1/presentation/quest/quest_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Состояние QR-сканера ---

// Используем AsyncValue для удобного управления состоянием загрузки/ошибки
// String - это результат сканирования (текст QR-кода)
typedef QrScanState = AsyncValue<String>;

// --- Notifier для управления сканированием ---

class QrScanNotifier extends StateNotifier<QrScanState> {
  final ScanQrCodeUseCase _scanQrCodeUseCase;
  final QuestNotifier _questNotifier;

  QrScanNotifier(this._scanQrCodeUseCase, this._questNotifier)
    : super(const QrScanState.data('')); // Начальное состояние: пусто, успех

  // 1. Метод для запуска процесса сканирования
  Future<void> scanQrCode() async {
    // 1.1. Устанавливаем состояние загрузки
    state = const QrScanState.loading();

    try {
      // 1.2. Вызываем Use Case для взаимодействия с TWA
      final qrResult = await _scanQrCodeUseCase.execute();

      // 1.3. Логика начисления баллов
      // В реальном приложении: здесь происходит проверка QR-кода на сервере.
      // Для демонстрации: проверяем, является ли код "FAKE_QR_CODE_123"

      //const expectedCode = 'FAKE_QR_CODE_123';
      const points = 20;

      if (qrResult.startsWith('FAKE_QR_CODE')) {
        // Мы используем QR-код как уникальный ID задания
        _questNotifier.addScore(points, qrResult);

        // 1.4. Устанавливаем состояние успеха
        state = QrScanState.data(
          'Успех! Получено $points баллов за код: $qrResult',
        );
      } else {
        // В случае реального кода, который не совпадает с ожидаемым (если бы их было много)
        state = QrScanState.error(
          'QR-код не распознан. Текст: $qrResult',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      // 1.5. Устанавливаем состояние ошибки
      state = QrScanState.error('Ошибка сканирования: $e', st);
      print('Ошибка при сканировании QR: $e');
    }
  }

  // 2. Сброс состояния после показа сообщения
  void resetState() {
    state = const QrScanState.data('');
  }
}

// 3. Провайдер для Notifier
final qrScanNotifierProvider =
    StateNotifierProvider<QrScanNotifier, QrScanState>((ref) {
      // Читаем Use Case (Domain Layer)
      final useCase = ref.watch(scanQrCodeUseCaseProvider);
      // Читаем QuestNotifier для начисления баллов
      final questNotifier = ref.watch(questNotifierProvider.notifier);

      return QrScanNotifier(useCase, questNotifier);
    });
