import 'package:flutter/material.dart';

class QrScanTab extends StatelessWidget {
  const QrScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем цветовую схему и стили текста из темы
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Иконка сканера с акцентным цветом
            Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: colorScheme.primary, // Cyan accent
            ),
            const SizedBox(height: 30),
            // Описание задачи
            Text(
              'Нажмите кнопку ниже, чтобы запустить TWA QR-сканер и найти секретный код в лабораториях.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme
                    .onBackground, // Primary Text (White/light color)
              ),
            ),
            const SizedBox(height: 40),
            // Кнопка CTA (будет стилизована согласно ElevatedButtonThemeData)
            ElevatedButton.icon(
              onPressed: () {
                // 💡 В будущем здесь будет вызов QrScanNotifier.scanQrCode()
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Запуск QR-сканера...'),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Сканировать QR-код'),
            ),
            const SizedBox(height: 20),
            // Второстепенная информация с Secondary (Neon Green) цветом
            // Text(
            //   '⚠️ Задание: QR-Квест',
            //   style: textTheme.labelSmall?.copyWith(
            //     color: colorScheme.secondary, // Neon Green accent
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
