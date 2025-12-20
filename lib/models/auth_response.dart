

class AuthResponse {
  final String userId;
  final String token;
  final String email;
  final String userName;
  final DateTime expiresAt;
  final List<String> roles;

  AuthResponse({
    required this.userId,
    required this.token,
    required this.email,
    required this.userName,
    required this.expiresAt,
    required this.roles,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['UserId'],
      token: json['Token'],
      email: json['Email'],
      userName: json['UserName'],
      expiresAt: DateTime.parse(json['ExpiresAt']),
      roles: List<String>.from(json['Roles'] ?? []),
    );
  }
}
