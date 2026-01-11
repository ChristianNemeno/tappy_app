import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tappy_app/providers/auth_provider.dart';
import 'package:tappy_app/screens/register_screen.dart';
import 'package:tappy_app/widgets/design/buttons.dart';
import 'package:tappy_app/widgets/design/fixed_width_container.dart';
import 'package:tappy_app/widgets/design/inline_message_banner.dart';
import 'package:tappy_app/widgets/design/surface_card.dart';

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
  void initState() {
    super.initState();
    print('[INFO] LoginScreen: Screen initialized');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print('[DEBUG] LoginScreen: Login button pressed');
    if (!_formKey.currentState!.validate()) {
      print('[DEBUG] LoginScreen: Form validation failed');
      return;
    }

    print(
      '[INFO] LoginScreen: Attempting login for ${_emailController.text.trim()}',
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      print('[SUCCESS] LoginScreen: Login successful');
    } else {
      print('[ERROR] LoginScreen: Login failed - ${authProvider.error}');
    }

    // Errors are rendered inline via InlineMessageBanner.
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
                                      'Welcome back',
                                      style: theme.textTheme.titleLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sign in to continue',
                                      style: theme.textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                    if (errorMessage != null &&
                                        errorMessage.trim().isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      InlineMessageBanner(
                                        title: 'Login failed',
                                        message: errorMessage,
                                        variant: InlineMessageVariant.error,
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                      ),
                                      keyboardType: TextInputType.emailAddress,
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
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                          ? 'Please enter a password'
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    PrimaryButton(
                                      label: 'Login',
                                      isLoading: isLoading,
                                      onPressed: _login,
                                    ),
                                    const SizedBox(height: 8),
                                    LinkButton(
                                      label: "Don't have an account? Register",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
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
