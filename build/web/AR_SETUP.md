# Инструкция по настройке MindAR для Image Tracking

## 1. Создание .mind файла

Файл `.mind` содержит скомпилированные маркеры для отслеживания изображений. Для его создания:

### Вариант 1: Использование MindAR CLI (рекомендуется)

1. Установите Node.js (если еще не установлен)
2. Установите MindAR CLI:
   ```bash
   npm install -g mind-ar
   ```

3. Подготовьте изображения-маркеры (JPG/PNG):
   - Размер: минимум 512x512 пикселей
   - Формат: JPG или PNG
   - Хороший контраст и четкость
   - Примеры: постеры, картинки, логотипы

4. Создайте директорию для маркеров:
   ```bash
   mkdir web/targets/images
   ```
   Поместите ваши изображения в эту папку (например: `target1.jpg`, `target2.jpg`)

5. Сгенерируйте .mind файл:
   ```bash
   mind-ar target web/targets/images --output web/targets/targets.mind
   ```

### Вариант 2: Использование онлайн-генератора

1. Перейдите на https://mind-ar.github.io/mind-ar-js-doc/tools/compile
2. Загрузите ваши изображения-маркеры
3. Скачайте сгенерированный `.mind` файл
4. Поместите его в `web/targets/targets.mind`

### Вариант 3: Использование существующего файла

Если у вас уже есть `.mind` файл, просто поместите его в `web/targets/targets.mind`

## 2. Подготовка 3D моделей

3D модели должны быть в формате **GLTF** или **GLB**.

### Где разместить модели:

1. Создайте директорию для моделей:
   ```bash
   mkdir web/models
   ```

2. Поместите ваши модели в эту папку:
   - `web/models/object1.gltf` (или `.glb`)
   - `web/models/object2.gltf`
   - и т.д.

### Где найти бесплатные модели:

- **Sketchfab**: https://sketchfab.com (фильтр: Free, GLTF)
- **Poly Haven**: https://polyhaven.com/models
- **TurboSquid**: https://www.turbosquid.com (есть бесплатные)
- **CGTrader**: https://www.cgtrader.com (есть бесплатные)

### Конвертация моделей:

Если у вас модель в другом формате (OBJ, FBX, etc.), используйте:
- **Blender** (бесплатно): https://www.blender.org
- **Online конвертеры**: https://products.aspose.app/3d/conversion

## 3. Настройка AR объектов в коде

В `ARImageTrackingScreen.dart` настройте объекты:

```dart
List<ArObject> _getDefaultArObjects() {
  return [
    ArObject(
      id: 'object_1',
      name: 'AR Объект 1',
      modelUrl: 'models/object1.gltf', // Путь относительно web/
      targetIndex: 0, // Индекс изображения в .mind файле (начинается с 0)
      position: const ArPosition(0, 0, 0.1),
      scale: const ArScale(0.1, 0.1, 0.1),
      metadata: {'points': 10, 'description': 'Первый AR объект'},
    ),
    ArObject(
      id: 'object_2',
      name: 'AR Объект 2',
      modelUrl: 'models/object2.gltf',
      targetIndex: 1, // Второе изображение в .mind файле
      position: const ArPosition(0, 0, 0.1),
      scale: const ArScale(0.1, 0.1, 0.1),
      metadata: {'points': 15, 'description': 'Второй AR объект'},
    ),
  ];
}
```

## 4. Структура файлов

После настройки структура должна выглядеть так:

```
web/
├── targets/
│   └── targets.mind          # Скомпилированные маркеры
├── models/
│   ├── object1.gltf         # 3D модель для первого маркера
│   └── object2.gltf         # 3D модель для второго маркера
├── index.html
└── ar_scene_logic.js
```

## 5. Проверка работы

1. Убедитесь, что файлы загружаются:
   - Откройте DevTools (F12)
   - Перейдите на вкладку Network
   - Проверьте, что `targets.mind` и модели загружаются без ошибок

2. Проверьте консоль браузера:
   - Должны быть сообщения о загрузке библиотек
   - Не должно быть ошибок 404 для файлов

## 6. Тестирование

1. Запустите приложение
2. Перейдите на экран AR
3. Наведите камеру на изображение-маркер
4. Должен появиться 3D объект

## Примечания

- **targetIndex** должен соответствовать порядку изображений в `.mind` файле (начинается с 0)
- Размер моделей: старайтесь использовать модели размером < 5MB для быстрой загрузки
- Оптимизация моделей: используйте инструменты типа `gltf-pipeline` для сжатия моделей

