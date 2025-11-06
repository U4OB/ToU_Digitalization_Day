import 'package:geolocator/geolocator.dart';

/// Сервис для работы с геолокацией.
class GeolocationService {
  /// Проверяет разрешения и статус службы геолокации.
  static Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Для Web TWA: просто сообщаем, что нужно включить геолокацию в устройстве.
      print('Служба геолокации отключена.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Доступ к местоположению запрещен.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Доступ к местоположению запрещен навсегда.');
      return false;
    }

    return true;
  }

  /// Получает текущую позицию пользователя.
  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) {
      return null;
    }

    try {
      // Используем высокую точность, необходимую для Geo-AR
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      return position;
    } catch (e) {
      print('Ошибка при получении местоположения: $e');
      return null;
    }
  }

  /// Получает поток обновлений местоположения (для Geo-AR полезно постоянное обновление).
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Обновлять при изменении на 10 метров
      ),
    );
  }
}
