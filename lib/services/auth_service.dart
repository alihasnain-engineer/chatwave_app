class AuthService {
  bool loggedIn = false;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == "admin@gmail.com" && password == "123456") {
      loggedIn = true;
      return true;
    }
    return false;
  }
}
