/// Модели данных для AR объектов и Image Tracking

/// AR объект, который будет отображаться при распознавании изображения
class ArObject {
  /// Уникальный идентификатор объекта
  final String id;

  /// Название объекта
  final String name;

  /// URL к 3D модели (GLTF/GLB)
  final String modelUrl;

  /// Индекс целевого изображения в .mind файле
  final int targetIndex;

  /// Позиция объекта относительно маркера (x, y, z)
  final ArPosition position;

  /// Масштаб объекта (x, y, z)
  final ArScale scale;

  /// Вращение объекта в градусах (x, y, z)
  final ArRotation rotation;

  /// Дополнительные метаданные (очки, описание и т.д.)
  final Map<String, dynamic>? metadata;

  ArObject({
    required this.id,
    required this.name,
    required this.modelUrl,
    required this.targetIndex,
    this.position = const ArPosition(0, 0, 0.1),
    this.scale = const ArScale(0.1, 0.1, 0.1),
    this.rotation = const ArRotation(0, 0, 0),
    this.metadata,
  });

  /// Преобразование в JSON для передачи в JavaScript
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'modelUrl': modelUrl,
      'targetIndex': targetIndex,
      'position': {'x': position.x, 'y': position.y, 'z': position.z},
      'scale': {'x': scale.x, 'y': scale.y, 'z': scale.z},
      'rotation': {'x': rotation.x, 'y': rotation.y, 'z': rotation.z},
      'metadata': metadata ?? {},
    };
  }

  factory ArObject.fromJson(Map<String, dynamic> json) {
    return ArObject(
      id: json['id'] as String,
      name: json['name'] as String,
      modelUrl: json['modelUrl'] as String,
      targetIndex: json['targetIndex'] as int,
      position: ArPosition.fromJson(json['position'] as Map<String, dynamic>),
      scale: ArScale.fromJson(json['scale'] as Map<String, dynamic>),
      rotation: ArRotation.fromJson(json['rotation'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Позиция в 3D пространстве
class ArPosition {
  final double x;
  final double y;
  final double z;

  const ArPosition(this.x, this.y, this.z);

  factory ArPosition.fromJson(Map<String, dynamic> json) {
    return ArPosition(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
      (json['z'] as num).toDouble(),
    );
  }
}

/// Масштаб в 3D пространстве
class ArScale {
  final double x;
  final double y;
  final double z;

  const ArScale(this.x, this.y, this.z);

  factory ArScale.fromJson(Map<String, dynamic> json) {
    return ArScale(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
      (json['z'] as num).toDouble(),
    );
  }
}

/// Вращение в 3D пространстве (в градусах)
class ArRotation {
  final double x;
  final double y;
  final double z;

  const ArRotation(this.x, this.y, this.z);

  factory ArRotation.fromJson(Map<String, dynamic> json) {
    return ArRotation(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
      (json['z'] as num).toDouble(),
    );
  }
}

/// Событие обнаружения AR объекта
class ArObjectFoundEvent {
  final String objectId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ArObjectFoundEvent({
    required this.objectId,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ArObjectFoundEvent.fromJson(Map<String, dynamic> json) {
    return ArObjectFoundEvent(
      objectId: json['objectId'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Состояние AR сессии
enum ArSessionState {
  /// AR не инициализирован
  uninitialized,

  /// AR инициализируется
  initializing,

  /// AR готов к работе
  ready,

  /// AR активен и отслеживает изображения
  tracking,

  /// AR приостановлен
  paused,

  /// Ошибка в AR сессии
  error,
}
