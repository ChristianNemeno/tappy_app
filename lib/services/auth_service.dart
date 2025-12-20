import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../utils/api_client.dart';


class AuthService {
    final ApiClient _apiClient;
    static const String _tokenKey = 'auth_token';
    static const String _expiryKey = 'token_expiry';

    AuthService(this._apiClient);

    Future<AuthResponse> register(String username, String email, String password)
    async {
        final response = await _apiClient.post('/auth/register', {
            'UserName': username,
            'Email': email,
            'Password': password,
        });

        if(response.statusCode == 200 || response.statusCode == 201){
          final data = json.decode(response.body);
          await _saveToken(data['Token'], data['ExpiresAt']);

          _apiClient.setToken(data['Token']);

          return AuthResponse.fromJson(data);
        }else{
          final error = json.decode(response.body);
          throw Exception (error['Message'] ?? error['message'] ??'Registration failed');
        }
    }

    



    Future<void> _saveToken(String token, String expiresAt) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_expiryKey, expiresAt);
      _apiClient.setToken(token);
    }

}


