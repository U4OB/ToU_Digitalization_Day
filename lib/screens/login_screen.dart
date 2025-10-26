import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/auth/auth_notifier.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsynsValue = ref.watch(authNotifierProvider);
    final isLoading = authAsynsValue.isLoading;
    final token = authAsynsValue.value;

    final isLoggedIn = token != null && token.isNotEmpty;

    ref.listen<AsyncValue<String>>(authNotifierProvider, (previous, next) {
      if (next.hasError && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("ошибка входа: ${next.error}")));
      } else if (next.hasValue &&
          next.value!.isNotEmpty &&
          previous?.isLoading == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Вход успешен! Перенаправление...')),
          );

          // 🔑 Ключевой момент: Навигация на HomeScreen
          // pushAndRemoveUntil удаляет все предыдущие маршруты, чтобы
          // пользователь не мог вернуться на экран логина по кнопке "Назад".
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false, // Удаляем все предыдущие маршруты
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text("Вход"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(
                labelText: 'Логин',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: (isLoggedIn || isLoading)
                  ? null
                  : () => _performLogin(ref, context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : Text(
                      isLoggedIn ? 'Вы вошли в систему' : 'Войти',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // lib/presentation/screens/login_screen.dart (внутри _performLogin)

  void _performLogin(WidgetRef ref, BuildContext context) async {
    ref
        .read(authNotifierProvider.notifier)
        .login(_loginController.text, _passwordController.text);
  }
}
