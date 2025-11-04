import 'dart:async';

import 'package:flutter_application_1/telegram/twa_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Интерфейс (Контракт)
abstract class ScanQrCodeUseCase {
  Future<String> execute();
}

// 2. Провайдер для Domain Layer
final scanQrCodeUseCaseProvider = Provider<ScanQrCodeUseCase>((ref) {
  // Внедряем реализацию из Data Layer
  return ScanQrCodeUseCaseImpl(ref.read(twaApiServiceProvider));
});
