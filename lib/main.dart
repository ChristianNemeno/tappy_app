import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tappy_app/providers/auth_provider.dart';
import 'package:tappy_app/providers/quiz_provider.dart';
import 'package:tappy_app/screens/main_shell.dart';
import 'package:tappy_app/screens/login_screen.dart';
import 'package:tappy_app/services/auth_service.dart';
import 'package:tappy_app/services/quiz_service.dart';
import 'package:tappy_app/utils/api_client.dart';
import 'package:tappy_app/providers/attempt_provider.dart';
import 'package:tappy_app/services/attempt_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiClient()),
        ProxyProvider<ApiClient, AuthService>(
          update: (_, client, __) => AuthService(client),
        ),
        ProxyProvider<ApiClient, QuizService>(
          update: (_, client, __) => QuizService(client),
        ),
        ProxyProvider<ApiClient, AttemptService>(
          update: (_, client, __) => AttemptService(client),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => QuizProvider(
            context.read<QuizService>(),
          ),
        ),
        ChangeNotifierProvider( 
          create: (context) => AttemptProvider(
            context.read<AttemptService>(),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 4, 80, 2),
        ),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (auth.isAuthenticated) {
            return const MainShell();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
