

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
    print('🔍 Parsing AuthResponse from JSON: $json');
    return AuthResponse(
      userId: json['userId'] as String,
      token: json['token'] as String,
      email: json['email'] as String,
      userName: json['userName'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}
