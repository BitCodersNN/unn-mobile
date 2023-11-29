class AuthData {
  final String login;
  final String password;

  const AuthData(this.login, this.password);

  static String getDefaultParameter() => 'None';
}