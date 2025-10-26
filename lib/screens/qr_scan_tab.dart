import 'package:flutter/material.dart';

class QrScanTab extends StatelessWidget {
  const QrScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 20),
          const Text(
            'Нажмите, чтобы запустить TWA QR-сканер.',
            style: TextStyle(fontSize: 18, color: Colors.deepPurple),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // 💡 В будущем здесь будет вызов QrScanNotifier.scanQrCode()
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Сканировать QR-код'),
          ),
        ],
      ),
    );
  }
}
