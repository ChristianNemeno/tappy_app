import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../utils/api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  static const String _tokenKey = 'auth_token';
  static const String _expiryKey = 'token_expiry';
  static const String _emailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userIdKey = 'user_id';
  static const String _rolesKey = 'user_roles';
  
  AuthService(this._apiClient);

  Future<AuthResponse> register(String username, String email, String password) async {
    final response = await _apiClient.post('/auth/register', {
      'UserName': username,
      'Email': email,
      'Password': password,
      'ConfirmPassword': password,
    });

    final data = json.decode(response.body);
    final authResult = AuthResult.fromJson(data);
    
    if (authResult.isSuccess && authResult.data != null) {
      final authResponse = authResult.data!;
      
      await _saveToken(authResponse.token, authResponse.expiresAt.toIso8601String());
      await _saveUserData(
        authResponse.userId,
        authResponse.email,
        authResponse.userName,
        authResponse.roles,
      );
      _apiClient.setToken(authResponse.token);
      
      return authResponse;
    } else {
      // Build error message from AuthResult
      String errorMsg = authResult.errorMessage ?? 'Registration failed';
      if (authResult.errors != null && authResult.errors!.isNotEmpty) {
        errorMsg += '\n${authResult.errors!.join('\n')}';
      }
      throw Exception(errorMsg);
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiClient.post('/auth/login', {
      'Email': email,
      'Password': password,
    });
    
    final data = json.decode(response.body);
    final authResult = AuthResult.fromJson(data);
    
    if (authResult.isSuccess && authResult.data != null) {
      final authResponse = authResult.data!;
      
      await _saveToken(authResponse.token, authResponse.expiresAt.toIso8601String());
      await _saveUserData(
        authResponse.userId,
        authResponse.email,
        authResponse.userName,
        authResponse.roles,
      );
      _apiClient.setToken(authResponse.token);
      
      return authResponse;
    } else {
      // Build error message from AuthResult
      String errorMsg = authResult.errorMessage ?? 'Login failed';
      if (authResult.errors != null && authResult.errors!.isNotEmpty) {
        errorMsg += '\n${authResult.errors!.join('\n')}';
      }
      throw Exception(errorMsg);
    }
  }

  Future<void> _saveToken(String token, String expiresAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_expiryKey, expiresAt);
  }

  Future<void> _saveUserData(String userId, String email, String userName, List<String> roles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_rolesKey, json.encode(roles));
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryStr = prefs.getString(_expiryKey);

    if (token != null && expiryStr != null) {
      try {
        final expiry = DateTime.parse(expiryStr);
        if (DateTime.now().isBefore(expiry)) {
          _apiClient.setToken(token);
          return token;
        }
      } catch (e) {
        await clearToken();
        return null;
      }
    }
    await clearToken();
    return null;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_rolesKey);
    _apiClient.clearToken();
  }

  Future<AuthResponse?> getSavedAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryStr = prefs.getString(_expiryKey);
    final userId = prefs.getString(_userIdKey);
    final email = prefs.getString(_emailKey);
    final userName = prefs.getString(_userNameKey);
    final rolesJson = prefs.getString(_rolesKey);

    if (token != null && expiryStr != null && userId != null && 
        email != null && userName != null && rolesJson != null) {
      try {
        final expiry = DateTime.parse(expiryStr);
        if (DateTime.now().isBefore(expiry)) {
          _apiClient.setToken(token);
          return AuthResponse(
            userId: userId,
            token: token,
            email: email,
            userName: userName,
            expiresAt: expiry,
            roles: List<String>.from(json.decode(rolesJson)),
          );
        }
      } catch (e) {
        await clearToken();
        return null;
      }
    }
    await clearToken();
    return null;
  }
}