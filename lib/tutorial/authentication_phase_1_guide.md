# Authentication Implementation Guide: Phase 1

This guide details the steps to implement the core authentication feature as outlined in Phase 1 of the implementation roadmap.

## 1. Project Structure and Dependencies

First, ensure your project has the required folder structure and dependencies.

### Folder Structure

Verify that your `lib` directory contains the following subdirectories. If not, create them:

```
lib/
├── models/
├── services/
├── providers/
└── screens/
```

### Dependencies

Add the necessary packages to your `pubspec.yaml` file.

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.1 # or latest version
  provider: ^6.1.2 # or latest version
  shared_preferences: ^2.2.3 # or latest version
```

After adding them, run `flutter pub get` in your terminal.

## 2. Data Models

The implementation guide from `lib/docs/implementation_guide.md` provides a complete example of `AuthService` which includes the `AuthResponse` model. For clarity, it's better to have models in their own files.

### `AuthResponse` Model

Create a file `lib/models/auth_response.dart`:

```dart
// lib/models/auth_response.dart

class AuthResponse {
  final String token;
  final String email;
  final String userName;
  final DateTime expiresAt;

  AuthResponse({
    required this.token,
    required this.email,
    required this.userName,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      email: json['email'],
      userName: json['userName'],
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}
```

## 3. Authentication Service (`AuthService`)

This service will handle all communication with the authentication endpoints of the API. The `implementation_guide.md` provides a complete example.

Create `lib/services/auth_service.dart`:

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../utils/api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  static const String _tokenKey = 'auth_token';
  static const String _expiryKey = 'token_expiry';

  AuthService(this._apiClient);

  Future<AuthResponse> register(String username, String email, String password) async {
    final response = await _apiClient.post('/auth/register', {
      'UserName': username,
      'Email': email,
      'Password': password,
      'ConfirmPassword': password, // Added missing ConfirmPassword
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      await _saveToken(data['Token'], data['ExpiresAt']); // Match backend casing
      _apiClient.setToken(data['Token']);
      return AuthResponse.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['Message'] ?? error['message'] ?? 'Registration failed');
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiClient.post('/auth/login', {
      'Email': email, // Match backend casing
      'Password': password,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data['Token'], data['ExpiresAt']); // Match backend casing
      _apiClient.setToken(data['Token']);
      return AuthResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid email or password');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['Message'] ?? error['message'] ?? 'Login failed');
    }
  }

  Future<void> _saveToken(String token, String expiresAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_expiryKey, expiresAt);
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
        // Invalid date format, clear token
        await clearToken();
        return null;
      }
    }
    await clearToken(); // Token is invalid or expired
    return null;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
    _apiClient.clearToken();
  }
}
```

**Note**: You'll also need the `ApiClient` class in `lib/utils/api_client.dart` as defined in the main implementation guide.

## 4. State Management (`AuthProvider`)

The `AuthProvider` will manage the authentication state and notify widgets of changes.

Create `lib/providers/auth_provider.dart`:

```dart
// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthResponse? _authData;
  bool _isLoading = true; // Start as true to handle auto-login check
  String? _error;

  AuthResponse? get authData => _authData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authData != null;

  AuthProvider(this._authService) {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final token = await _authService.getSavedToken();
    if (token != null) {
        // This is a simplified auto-login. A robust implementation would
        // fetch fresh user data from an endpoint like `/auth/me`
        // or store encrypted user data locally.
        final prefs = await SharedPreferences.getInstance();
        // The following lines are placeholders and should be replaced with real data
        _authData = AuthResponse(
            token: token,
            email: 'user@example.com', // Placeholder
            userName: 'user', // Placeholder
            expiresAt: DateTime.parse(prefs.getString(_expiryKey)!),
        );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final result = await _authService.login(email, password);
      _authData = result;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _setLoading(true);
    try {
      final result = await _authService.register(username, email, password);
      _authData = result;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    _authData = null;
    await _authService.clearToken();
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}
```

## 5. UI Integration

Finally, integrate the `AuthProvider` with your UI.

### `main.dart` Setup

Configure `MultiProvider` in your `main.dart` to provide the services and providers to your widget tree.

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tappy_app/providers/auth_provider.dart';
import 'package:tappy_app/screens/login_screen.dart';
import 'package:tappy_app/services/auth_service.dart';
import 'package:tappy_app/utils/api_client.dart';

// A placeholder for your app's main screen after login
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Welcome ${authProvider.authData?.userName ?? ''}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You are logged in!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => authProvider.logout(),
              child: const Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}


void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiClient()),
        ProxyProvider<ApiClient, AuthService>(
          update: (_, client, __) => AuthService(client),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAPCET Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 4, 80, 2)),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          if (auth.isAuthenticated) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
```

### `login_screen.dart` Example

Enhance your `LoginScreen` to use the `AuthProvider`.

```dart
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tappy_app/providers/auth_provider.dart';
import 'package:tappy_app/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'An unknown error occurred')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter an email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter a password' : null,
                ),
                const SizedBox(height: 20),
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    if (auth.isLoading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _login,
                      child: const Text('Login'),
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### `register_screen.dart` Example
Create `lib/screens/register_screen.dart`. The implementation is very similar to `LoginScreen`.

```dart
// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tappy_app/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

 @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      if (mounted) Navigator.of(context).pop();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(authProvider.error ?? 'An unknown error occurred')),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter a username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter an email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 20),
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    if (auth.isLoading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _register,
                      child: const Text('Register'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Acceptance Criteria Checklist

Once you've implemented these steps, verify against the acceptance criteria:
-   [ ] User can register with validation.
-   [ ] User can login and receive a JWT.
-   [ ] The JWT is stored in `SharedPreferences`.
-   [ ] When the app restarts, it automatically logs the user in if the token is still valid.
-   [ ] Errors during login or registration are shown to the user.

```