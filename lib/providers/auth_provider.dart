import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';
import 'dart:developer' as developer;



class AuthProvider extends ChangeNotifier {

  final AuthService _authService;

  AuthResponse? _authData;
  bool _isLoading = true;
  String? _error;

  // these are just getters
  AuthResponse? get authData => _authData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authData != null;
  
  AuthProvider(this._authService){
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
      try{
        _authData = await _authService.getSavedAuthData();
      }catch(e){
        _authData = null;
        _error = e.toString();
      }
      _isLoading = false;
      notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try{
      final result = await _authService.login(email, password);
      _authData = result;
      _log(_authData.toString());
      _log('inside login method of provider');
      _setLoading(false);
      return true;
    }catch(e){
      _log('Login failed', error: e);
      _setError(e.toString());
      _setLoading(false);
      return false;
    }

  }

  Future<bool> register(String username, String email, String password) async
  {
    _setLoading(true);
    print(' Attempting registration for: $email');

    try{
      final result = await _authService.register(username, email, password);
      _authData = result;
      print(' Registration successful: ${_authData?.userName}');
      print(' Auth data: $_authData');
      _setLoading(false);
      return true;
    }catch(e){
      print(' Registration failed: $e');
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    
    _authData = null;
    await _authService.clearToken();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;  
    notifyListeners();
  }
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: 'AuthProvider', error: error, stackTrace: stackTrace);
  }


}