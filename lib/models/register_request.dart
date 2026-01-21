class RegisterRequest {
  final String userName;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterRequest({
    required this.userName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}
