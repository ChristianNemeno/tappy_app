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
  void initState() {
    super.initState();
    print('[INFO] RegisterScreen: Screen initialized');
  }

 @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    print('[DEBUG] RegisterScreen: Register button pressed');
    
    if (!_formKey.currentState!.validate()) {
      print('[DEBUG] RegisterScreen: Form validation failed');
      return;
    }

    print('[DEBUG] RegisterScreen: Form validation passed');
    print('[INFO] RegisterScreen: Attempting registration for ${_usernameController.text.trim()}');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      print('[SUCCESS] RegisterScreen: Registration successful');
      if (mounted) Navigator.of(context).pop();
    } else {
      print('[ERROR] RegisterScreen: Registration failed - ${authProvider.error}');
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