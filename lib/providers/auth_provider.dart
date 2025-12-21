import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';


class AuthProvider extends ChangeNotifier {

  final AuthService _authService;

  AuthResponse? _authData;
  bool _isLoading = true;
  String? _error;

  
  
  AuthProvider(this._authService){
    
  }




}