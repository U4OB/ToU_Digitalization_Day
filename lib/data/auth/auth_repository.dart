class AuthRepository {
  Future<String> login(String username, String password) async {
    print('AuthRepository: Attempting login for user $username');

    await Future.delayed(const Duration(seconds: 2));

    if (username == 'user' && password == 'password') {
      print('AuthRepository: Успешный вход.');
      return 'some_token';
    } else {
      print('AuthRepository: Неверные учетные данные.');
      throw Exception('Неверный логин или пароль.');
    }
  }
}
