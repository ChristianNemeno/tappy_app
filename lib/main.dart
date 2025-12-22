import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tappy_app/providers/auth_provider.dart';
import 'package:tappy_app/screens/login_screen.dart';
import 'package:tappy_app/services/auth_service.dart';
import 'package:tappy_app/utils/api_client.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(      
      appBar: AppBar(
        title: Text('Welcome ${authProvider.authData?.userName ?? 'User'}'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('You are logged in!'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => authProvider.logout(),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
      colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 4, 80, 2)),
      ),
      home: const LoginScreen(),
      // routes: {
      //   '/home' : (_) => const AppShell(),

      // }
    );
  }
}
