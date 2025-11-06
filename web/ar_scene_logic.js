// Глобальные переменные для управления AR сценой
let arScene = null;
let mindarSystem = null;
let isTracking = false;
let arObjects = [];

/**
 * Ожидание готовности A-Frame и MindAR
 */
function waitForARReady() {
    return new Promise((resolve, reject) => {
        // Проверяем, загружен ли A-Frame
        if (typeof AFRAME === 'undefined') {
            console.log('⏳ Ожидание загрузки A-Frame...');
            const checkAFrame = setInterval(() => {
                if (typeof AFRAME !== 'undefined') {
                    clearInterval(checkAFrame);
                    waitForScene();
                }
            }, 100);
            setTimeout(() => {
                clearInterval(checkAFrame);
                reject(new Error('A-Frame не загрузился'));
            }, 10000);
        } else {
            waitForScene();
        }

        function waitForScene() {
            arScene = document.querySelector('a-scene');
            if (!arScene) {
                console.log('⏳ Ожидание создания a-scene...');
                const checkScene = setInterval(() => {
                    arScene = document.querySelector('a-scene');
                    if (arScene) {
                        clearInterval(checkScene);
                        waitForSystem();
                    }
                }, 100);
                setTimeout(() => {
                    clearInterval(checkScene);
                    reject(new Error('a-scene не создана'));
                }, 10000);
            } else {
                waitForSystem();
            }
        }

        function waitForSystem() {
            // Ждем события 'loaded' на сцене
            if (arScene.hasLoaded) {
                checkSystem();
            } else {
                arScene.addEventListener('loaded', () => {
                    checkSystem();
                });
            }

            function checkSystem() {
                // Даем время на регистрацию системы MindAR
                setTimeout(() => {
                    // Проверяем все доступные системы
                    const allSystems = Object.keys(arScene.systems || {});
                    console.log('📋 Доступные системы A-Frame:', allSystems);
                    
                    mindarSystem = arScene.systems['mindar-image-system'];
                    if (mindarSystem) {
                        console.log('✅ MindAR system готов');
                        resolve();
                    } else {
                        console.log('⏳ Ожидание регистрации MindAR system...');
                        console.log('📋 Проверяем наличие MindAR компонента:', typeof MINDAR !== 'undefined' ? '✅' : '❌');
                        
                        // Пробуем еще несколько раз с увеличивающейся задержкой
                        let attempts = 0;
                        const maxAttempts = 10;
                        const checkInterval = setInterval(() => {
                            attempts++;
                            mindarSystem = arScene.systems['mindar-image-system'];
                            if (mindarSystem) {
                                console.log(`✅ MindAR system готов (попытка ${attempts})`);
                                clearInterval(checkInterval);
                                resolve();
                            } else if (attempts >= maxAttempts) {
                                console.error('❌ MindAR system не зарегистрирована после', maxAttempts, 'попыток');
                                console.error('📋 Доступные системы:', Object.keys(arScene.systems || {}));
                                clearInterval(checkInterval);
                                reject(new Error('MindAR system не зарегистрирована. Проверьте загрузку скриптов MindAR.'));
                            } else {
                                console.log(`⏳ Попытка ${attempts}/${maxAttempts}...`);
                            }
                        }, 300);
                    }
                }, 500); // Увеличиваем начальную задержку
            }
        }
    });
}

/**
 * [GLOBAL FUNCTION] Инициализирует AR-сцену MindAR.
 * Вызывается из Flutter через ArInteropManager.
 * @param {string} arObjectsJson - JSON-строка со списком ArObject.
 * @param {string} mindFilePath - Путь к .mind файлу с маркерами.
 * @returns {Promise} Promise, который разрешается при успешной инициализации
 */
function initializeArScene(arObjectsJson, mindFilePath = 'targets/targets.mind') {
    // Явно возвращаем Promise для совместимости с Dart
    return new Promise((resolve, reject) => {
        // Используем async IIFE (Immediately Invoked Function Expression)
        (async () => {
            try {
                console.log('🎬 Инициализация AR сцены...');
                console.log('📋 Проверка состояния перед инициализацией:');
                console.log('  - AFRAME:', typeof AFRAME !== 'undefined' ? '✅ загружен' : '❌ не загружен');
                console.log('  - a-scene:', document.querySelector('a-scene') ? '✅ найдена' : '❌ не найдена');
                
                // Ждем готовности AR системы
                console.log('⏳ Ожидание готовности AR системы...');
                await waitForARReady();
                console.log('✅ AR система готова');
                
                // Парсим объекты
                const objects = JSON.parse(arObjectsJson);
                arObjects = objects;
                
                // Получаем систему MindAR (должна быть уже готова)
                if (!mindarSystem) {
                    mindarSystem = arScene.systems['mindar-image-system'];
                    if (!mindarSystem) {
                        console.error('❌ MindAR system не найден после ожидания');
                        console.error('📋 Доступные системы:', Object.keys(arScene.systems || {}));
                        notifyError('MindAR system не инициализирован');
                        reject(new Error('MindAR system не инициализирован'));
                        return;
                    }
                }
                
                console.log('✅ MindAR system найдена:', mindarSystem);

                // Обновляем путь к .mind файлу, если указан другой
                if (mindFilePath !== 'targets/targets.mind') {
                    arScene.setAttribute('mindar-image', {
                        imageTargetSrc: mindFilePath,
                        autoStart: false,
                        filterMinCF: 0.0001,
                        filterBeta: 1
                    });
                }

                console.log(`✅ MindAR: Получено ${objects.length} целей для отслеживания`);

                // Очищаем предыдущие объекты (если есть)
                clearArObjects();

                // Размещаем объекты на сцене
                objects.forEach((obj, index) => {
                    placeArObject(obj, index);
                });

                // Уведомляем о готовности
                notifyStateChanged('ready');
                resolve(); // Разрешаем Promise при успехе
                
            } catch (e) {
                console.error('❌ Ошибка инициализации AR Scene:', e);
                notifyError(`Ошибка инициализации: ${e.message}`);
                reject(e); // Отклоняем Promise при ошибке
            }
        })(); // Вызываем async функцию немедленно
    });
}

// Экспортируем функцию глобально после её определения
if (typeof window !== 'undefined') {
    window.initializeArScene = initializeArScene;
    console.log('✅ initializeArScene экспортирована глобально');
}

/**
 * Создает a-entity (якорь) для каждого целевого изображения.
 * @param {Object} obj - Объект AR с данными (id, modelUrl, targetIndex и т.д.)
 * @param {number} index - Индекс объекта в массиве
 */
function placeArObject(obj, index) {
    try {
        // MindAR использует 'targetIndex' - индекс изображения в файле targets.mind
        const targetIndex = obj.targetIndex !== undefined ? obj.targetIndex : index;

        // Создаем якорь MindAR для целевого изображения
        const anchor = document.createElement('a-entity');
        anchor.setAttribute('mindar-image-target', `targetIndex: ${targetIndex}`);
        anchor.setAttribute('id', `ar-anchor-${obj.id}`);
        anchor.setAttribute('name', obj.name); // Для удобства отладки
        
        // Создаем 3D-модель
        const model = document.createElement('a-entity');
        model.setAttribute('gltf-model', `url(${obj.modelUrl})`);
        
        // Применяем трансформации
        const pos = obj.position || { x: 0, y: 0, z: 0.1 };
        const scale = obj.scale || { x: 0.1, y: 0.1, z: 0.1 };
        const rot = obj.rotation || { x: 0, y: 0, z: 0 };
        
        model.setAttribute('position', `${pos.x} ${pos.y} ${pos.z}`);
        model.setAttribute('scale', `${scale.x} ${scale.y} ${scale.z}`);
        model.setAttribute('rotation', `${rot.x} ${rot.y} ${rot.z}`);

        // Добавляем интерактивность (клик)
        model.setAttribute('class', 'ar-object');
        model.setAttribute('data-object-id', obj.id);
        model.setAttribute('cursor', 'rayOrigin: mouse');
        
        // Добавляем визуальную обратную связь при наведении
        model.addEventListener('mouseenter', () => {
            const currentScale = model.getAttribute('scale');
            model.setAttribute('animation__hover', {
                property: 'scale',
                to: `${currentScale.x * 1.2} ${currentScale.y * 1.2} ${currentScale.z * 1.2}`,
                dur: 200
            });
        });

        model.addEventListener('mouseleave', () => {
            const scale = obj.scale || { x: 0.1, y: 0.1, z: 0.1 };
            model.setAttribute('animation__hover', {
                property: 'scale',
                to: `${scale.x} ${scale.y} ${scale.z}`,
                dur: 200
            });
        });

        // Обработка клика по объекту
        model.addEventListener('click', () => {
            handleObjectClick(obj);
        });

        anchor.appendChild(model);
        arScene.appendChild(anchor);

        // События отслеживания изображения
        anchor.addEventListener('targetFound', () => {
            console.log(`🎯 JS: Цель "${obj.name}" (${obj.id}) найдена!`);
            if (window.arObjectFound) {
                window.arObjectFound(obj.id);
            }
        });

        anchor.addEventListener('targetLost', () => {
            console.log(`❌ JS: Цель "${obj.name}" (${obj.id}) потеряна.`);
            if (window.arObjectLost) {
                window.arObjectLost(obj.id);
            }
        });

        console.log(`✅ AR объект "${obj.name}" размещен на сцене (targetIndex: ${targetIndex})`);
        
    } catch (e) {
        console.error(`❌ Ошибка размещения AR объекта ${obj.id}:`, e);
    }
}

/**
 * Обработка клика по AR объекту
 * @param {Object} obj - Объект AR
 */
function handleObjectClick(obj) {
    console.log(`🖱️ Клик по AR объекту: ${obj.name} (${obj.id})`);
    
    // Можно добавить визуальные эффекты при клике
    const anchor = document.querySelector(`#ar-anchor-${obj.id}`);
    if (anchor) {
        const model = anchor.querySelector('.ar-object');
        if (model) {
            // Эффект пульсации
            model.setAttribute('animation__click', {
                property: 'scale',
                to: '1.3 1.3 1.3',
                dur: 300,
                easing: 'easeOutElastic'
            });
            
            setTimeout(() => {
                const scale = obj.scale || { x: 0.1, y: 0.1, z: 0.1 };
                model.setAttribute('scale', `${scale.x} ${scale.y} ${scale.z}`);
            }, 300);
        }
    }
}

/**
 * Очистка всех AR объектов со сцены
 */
function clearArObjects() {
    if (!arScene) return;
    
    const anchors = arScene.querySelectorAll('[mindar-image-target]');
    anchors.forEach(anchor => {
        arScene.removeChild(anchor);
    });
    
    console.log('🧹 AR объекты очищены');
}

/**
 * [GLOBAL FUNCTION] Запуск AR отслеживания
 */
function startArTracking() {
    try {
        if (!mindarSystem) {
            console.error('❌ MindAR system не инициализирован');
            notifyError('MindAR system не инициализирован');
            return;
        }

        if (isTracking) {
            console.warn('⚠️ AR отслеживание уже запущено');
            return;
        }

        console.log('▶️ Запуск AR отслеживания...');
        console.log('📹 Запрос доступа к камере...');
        
        // Запускаем отслеживание (MindAR автоматически запросит доступ к камере)
        // start() - синхронная функция, не возвращает Promise
        try {
            mindarSystem.start();
            isTracking = true;
            console.log('✅ AR отслеживание запущено');
            
            // Ждем немного и проверяем состояние камеры
            setTimeout(() => {
                const video = arScene.querySelector('video');
                if (video) {
                    console.log('✅ Видео элемент найден, камера должна быть активна');
                    // Проверяем, что видео играет
                    if (video.readyState >= 2) {
                        console.log('✅ Видео загружено и готово к воспроизведению');
                    }
                } else {
                    console.warn('⚠️ Видео элемент не найден в сцене');
                }
            }, 1000);
            
            notifyStateChanged('tracking');
        } catch (startError) {
            console.error('❌ Ошибка запуска отслеживания:', startError);
            notifyError(`Ошибка запуска: ${startError.message || startError}`);
            throw startError;
        }
        
    } catch (e) {
        console.error('❌ Ошибка запуска отслеживания:', e);
        notifyError(`Ошибка запуска: ${e.message}`);
    }
}

/**
 * [GLOBAL FUNCTION] Остановка AR отслеживания
 */
function stopArTracking() {
    try {
        if (!mindarSystem) {
            return;
        }

        if (!isTracking) {
            return;
        }

        console.log('⏹️ Остановка AR отслеживания...');
        mindarSystem.stop();
        isTracking = false;
        notifyStateChanged('paused');
        
    } catch (e) {
        console.error('❌ Ошибка остановки отслеживания:', e);
        notifyError(`Ошибка остановки: ${e.message}`);
    }
}

/**
 * [GLOBAL FUNCTION] Пауза AR отслеживания
 */
function pauseArTracking() {
    stopArTracking(); // В MindAR пауза = остановка
}

/**
 * Уведомление об изменении состояния
 * @param {string} state - Состояние ('uninitialized', 'initializing', 'ready', 'tracking', 'paused', 'error')
 */
function notifyStateChanged(state) {
    if (window.arStateChanged) {
        window.arStateChanged(state);
    }
}

/**
 * Уведомление об ошибке
 * @param {string} error - Текст ошибки
 */
function notifyError(error) {
    console.error('❌ AR Error:', error);
    if (window.arError) {
        window.arError(error);
    }
    notifyStateChanged('error');
}

// Функция будет определена ниже, но мы экспортируем её глобально после определения

// Инициализация при загрузке страницы
document.addEventListener('DOMContentLoaded', () => {
    console.log('📄 DOM загружен, ожидание инициализации AR...');
    notifyStateChanged('uninitialized');
    
    // Проверяем доступность библиотек
    if (typeof AFRAME === 'undefined') {
        console.warn('⚠️ A-Frame не загружен');
    } else {
        console.log('✅ A-Frame загружен');
    }
    
    // Проверяем наличие a-scene
    const scene = document.querySelector('a-scene');
    if (scene) {
        console.log('✅ a-scene найдена в DOM');
        // Ждем загрузки сцены
        scene.addEventListener('loaded', () => {
            console.log('✅ a-scene загружена');
            // Проверяем наличие MindAR системы
            setTimeout(() => {
                const system = scene.systems['mindar-image-system'];
                if (system) {
                    console.log('✅ MindAR system зарегистрирована');
                } else {
                    console.warn('⚠️ MindAR system еще не зарегистрирована (это нормально, если инициализация еще не вызвана)');
                    console.log('📋 Доступные системы:', Object.keys(scene.systems || {}));
                }
            }, 500);
        });
    } else {
        console.warn('⚠️ a-scene не найдена в DOM');
    }
    
    // Проверяем, что функция доступна
    console.log('📋 initializeArScene доступна:', typeof initializeArScene !== 'undefined' ? '✅' : '❌');
});

// Обработка ошибок загрузки A-Frame
window.addEventListener('error', (event) => {
    if (event.message && event.message.includes('aframe') || event.message.includes('mindar')) {
        notifyError(`Ошибка загрузки библиотеки: ${event.message}`);
    }
});
