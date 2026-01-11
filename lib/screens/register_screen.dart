import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tappy_app/providers/auth_provider.dart';
import 'package:tappy_app/widgets/design/buttons.dart';
import 'package:tappy_app/widgets/design/fixed_width_container.dart';
import 'package:tappy_app/widgets/design/inline_message_banner.dart';
import 'package:tappy_app/widgets/design/surface_card.dart';

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
    print(
      '[INFO] RegisterScreen: Attempting registration for ${_usernameController.text.trim()}',
    );
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
      print(
        '[ERROR] RegisterScreen: Registration failed - ${authProvider.error}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: FixedWidthContainer(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: SurfaceCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(16),
                        child: Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            final isLoading = auth.isLoading;
                            final errorMessage = auth.error;

                            return AbsorbPointer(
                              absorbing: isLoading,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Create your account',
                                      style: theme.textTheme.titleLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Start taking quizzes in seconds',
                                      style: theme.textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                    if (errorMessage != null &&
                                        errorMessage.trim().isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      InlineMessageBanner(
                                        title: 'Registration failed',
                                        message: errorMessage,
                                        variant: InlineMessageVariant.error,
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _usernameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Username',
                                      ),
                                      textInputAction: TextInputAction.next,
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                          ? 'Please enter a username'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                          ? 'Please enter an email'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _passwordController,
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                      ),
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _register(),
                                      validator: (value) =>
                                          (value == null || value.length < 6)
                                          ? 'Password must be at least 6 characters'
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    PrimaryButton(
                                      label: 'Register',
                                      isLoading: isLoading,
                                      onPressed: _register,
                                    ),
                                    const SizedBox(height: 8),
                                    LinkButton(
                                      label: 'Already have an account? Login',
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
