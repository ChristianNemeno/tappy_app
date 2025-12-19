# Flutter Basic Navigation Guide: Login & Register

This guide explains how to implement basic navigation between your `LoginScreen` and `RegisterScreen` using buttons.

There are two common ways to handle navigation in Flutter:
1.  **Direct Navigation**: Using `Navigator.push()` with a `MaterialPageRoute`. It's simple and good for small apps.
2.  **Named Routes**: Defining a map of routes for your entire application. This is the recommended approach for scalability and clean code.

---

## 1. Direct Navigation (`MaterialPageRoute`)

With this method, you create a new "route" (which is essentially the screen widget) on the fly and push it onto the navigation stack.

### Step 1: Add a "Register" button to your Login Screen

In `lib/screens/login_screen.dart`, add another button to allow users to navigate to the registration page.

```dart
// lib/screens/login_screen.dart

// ... inside the Column's children array in your build method:
            ElevatedButton(
              onPressed: () {
                // Handle login logic here
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0), // Add some space
            TextButton(
              onPressed: () {
                // TODO: Navigate to Register Screen
              },
              child: const Text("Don't have an account? Register"),
            ),
// ...
```

### Step 2: Implement the Navigation

Now, let's implement the `onPressed` logic using `Navigator.push`.

First, import the register screen at the top of `lib/screens/login_screen.dart`:
```dart
import 'package:tappy_app/screens/register_screen.dart';
```

Then, update the `onPressed` callback:

```dart
// lib/screens/login_screen.dart

// ...
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text("Don't have an account? Register"),
            ),
// ...
```
When you press this button, the `RegisterScreen` will slide in. The `AppBar` on the `RegisterScreen` will automatically include a back button to return to the `LoginScreen`.

---

## 2. Named Routes (Recommended)

Named routes are a more organized way to handle navigation, especially as your app grows.

### Step 1: Define Your Routes

In `lib/main.dart`, you'll define all your app's top-level routes.

First, import `register_screen.dart` and `login_screen.dart`:
```dart
// lib/main.dart
import 'package:tappy_app/screens/login_screen.dart';
import 'package:tappy_app/screens/register_screen.dart';
```

Next, update your `MaterialApp` widget. Instead of `home`, use `initialRoute` and the `routes` property.

```dart
// lib/main.dart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 4, 80, 2)),
      ),
      // Instead of 'home', define an initial route
      initialRoute: '/login', 
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        // Add other routes here
      },
    );
  }
}
```

### Step 2: Navigate Using Named Routes

Now, you can navigate by referencing the name of the route.

In `lib/screens/login_screen.dart`, add the button as before, but this time use `Navigator.pushNamed`.

```dart
// lib/screens/login_screen.dart

// ... inside the Column's children array in your build method:
            ElevatedButton(
              onPressed: () {
                // Handle login logic here
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0), // Add some space
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Don't have an account? Register"),
            ),
// ...
```

### Going Back

The `AppBar` automatically gives you a back button. If you wanted to navigate back programmatically (for example, after a user registers successfully), you could use `Navigator.pop(context);`.

To add a button on the `RegisterScreen` to explicitly go back to the `LoginScreen`, you could do this:

```dart
// lib/screens/register_screen.dart

// ... inside the Column's children array:
            ElevatedButton(
              onPressed: () {
                // Handle registration logic here
              },
              child: const Text('Register'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // This takes you back to the previous screen (Login)
              },
              child: const Text("Already have an account? Login"),
            ),
//...
```

This approach keeps your navigation logic clean and centralized.
