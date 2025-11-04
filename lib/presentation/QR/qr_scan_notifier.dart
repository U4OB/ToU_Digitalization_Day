import 'package:flutter_application_1/telegram/scan_qr_code_use_case.dart';
import 'package:flutter_application_1/presentation/quest/quest_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Модель Ответа от Бэкенда ---
// Описывает, что мы ожидаем получить от сервера после отправки QR-кода.
class BackendResponse {
  final String qrCodeValue;
  final String aiType; // Например: 'gemini', 'assemblyai'
  final bool isCodeValid;

  const BackendResponse({
    required this.qrCodeValue,
    required this.aiType,
    required this.isCodeValid,
  });

  // Моковый метод, имитирующий получение ответа от сервера
  static Future<BackendResponse> mockBackendCheck(String code) async {
    // Имитация сетевой задержки (проверка на сервере)
    await Future.delayed(const Duration(seconds: 1));

    // Логика "бэкенда":
    // 1. Проверяем, что код начинается с "LAB_" (имитация распознанного кода лаборатории)
    if (code.startsWith('LAB_')) {
      final labId = code.split('_')[1];

      // Имитируем, что разные коды вызывают разные нейронки
      if (labId == 'QUIZ' || labId == '001') {
        return BackendResponse(
          qrCodeValue: code,
          aiType: 'gemini', // Требуется для квиза или чата
          isCodeValid: true,
        );
      } else if (labId == 'SCAN' || labId == '002') {
        return BackendResponse(
          qrCodeValue: code,
          aiType: 'assemblyai', // Требуется для распознавания аудио/речи
          isCodeValid: true,
        );
      }
    }

    // В случае недействительного или неизвестного кода
    return BackendResponse(
      qrCodeValue: code,
      aiType: '', // Нет нейронки для запуска
      isCodeValid: false,
    );
  }
}

// --- Состояние QR-сканера ---

// Теперь AsyncValue хранит объект BackendResponse
typedef QrScanState = AsyncValue<BackendResponse>;

// --- Notifier для управления сканированием ---

class QrScanNotifier extends StateNotifier<QrScanState> {
  final ScanQrCodeUseCase _scanQrCodeUseCase;
  // QuestNotifier остается для начисления баллов, если это потребуется после AI-задачи
  final QuestNotifier _questNotifier;

  QrScanNotifier(this._scanQrCodeUseCase, this._questNotifier)
    : super(
        const QrScanState.data(
          BackendResponse(qrCodeValue: '', aiType: '', isCodeValid: false),
        ),
      ); // Начальное состояние

  // 1. Метод для запуска процесса сканирования и проверки на бэкенде
  Future<void> scanQrCode() async {
    // 1.1. Устанавливаем состояние загрузки
    state = const QrScanState.loading();

    try {
      // 1.2. Вызываем Use Case для взаимодействия с TWA
      final qrResult = await _scanQrCodeUseCase.execute();

      // 1.3. Имитация POST-запроса на сервер для проверки кода и получения AI-типа
      final backendResponse = await BackendResponse.mockBackendCheck(qrResult);

      if (backendResponse.isCodeValid) {
        // Успех: код действителен и есть тип нейросети
        // Логика начисления баллов пока отключена,
        // так как баллы должны начисляться после прохождения AI-задачи.

        // 1.4. Устанавливаем состояние успеха
        state = QrScanState.data(backendResponse);
      } else {
        // Код недействителен или не распознан
        state = QrScanState.error(
          'QR-код недействителен: ${backendResponse.qrCodeValue}',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      // 1.5. Устанавливаем состояние ошибки сканирования/сети
      state = QrScanState.error('Ошибка сканирования или связи: $e', st);
      print('Ошибка при сканировании QR: $e');
    }
  }

  // 2. Сброс состояния после показа сообщения или навигации
  void resetState() {
    state = const QrScanState.data(
      BackendResponse(qrCodeValue: '', aiType: '', isCodeValid: false),
    );
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
