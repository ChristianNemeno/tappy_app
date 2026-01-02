

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

class AuthResult {
  final bool succeeded;
  final AuthResponse? data;
  final String? errorMessage;
  final List<String>? errors;

  AuthResult({
    required this.succeeded,
    this.data,
    this.errorMessage,
    this.errors,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing AuthResult from JSON: $json');
    
    // Success case - data is at root level
    if (json.containsKey('userId') && json.containsKey('token')) {
      return AuthResult(
        succeeded: true,
        data: AuthResponse.fromJson(json),
        errorMessage: null,
        errors: null,
      );
    }
    
    // Error case - has message and errors
    if (json.containsKey('message')) {
      return AuthResult(
        succeeded: false,
        data: null,
        errorMessage: json['message'] as String?,
        errors: json['errors'] != null 
            ? List<String>.from(json['errors']) 
            : null,
      );
    }
    
    // Fallback
    throw Exception('Invalid AuthResult JSON structure: $json');
  }

  bool get isSuccess => succeeded && data != null;
  bool get isFailure => !succeeded;
}
