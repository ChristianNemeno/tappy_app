# Tappy Quiz App - AI Coding Agent Instructions

## Project Overview

Flutter mobile app for the TAPCET quiz system, using Provider for state management and communicating with a .NET backend API. The app supports authentication, quiz browsing, quiz-taking, and attempt history tracking.

## Architecture

**Three-Layer Pattern:**
- **Services** ([lib/services/](lib/services/)) - HTTP API calls via `ApiClient`, return DTOs
- **Providers** ([lib/providers/](lib/providers/)) - `ChangeNotifier` state management, business logic
- **Screens** ([lib/screens/](lib/screens/)) - UI consuming providers via `Consumer<T>` or `context.read/watch`

**Dependency Injection:** All dependencies configured in [lib/main.dart](lib/main.dart) using `MultiProvider`:
```dart
Provider(create: (_) => ApiClient()),
ProxyProvider<ApiClient, AuthService>(...),
ChangeNotifierProvider(create: (ctx) => AuthProvider(ctx.read<AuthService>()))
```

## Critical Patterns

### API Client & Authentication
- **Singleton ApiClient** ([lib/utils/api_client.dart](lib/utils/api_client.dart)) - Manages base URL and Bearer token
- Token set via `apiClient.setToken(token)` after login/register
- All authenticated endpoints automatically include `Authorization: Bearer {token}` header
- **Base URL:** Currently hardcoded in `ApiClient` - search for `baseUrl` to change

### Model JSON Parsing
Models use **manual `fromJson`** constructors (no json_serializable generation):
```dart
factory Quiz.fromJson(Map<String, dynamic> json) {
  return Quiz(
    id: json['Id'],  // Note: PascalCase from backend
    title: json['Title'],
    // ...
  );
}
```
**Backend uses PascalCase** keys (e.g., `Id`, `Title`, `CreatedAt`), **not camelCase**.

### Provider Pattern
- Providers expose getters for state, never direct field access
- Use `notifyListeners()` after state changes
- Loading states: `_setLoading(true)` → operation → `_setLoading(false)`
- Error handling: Catch exceptions, call `_setError(message)`, return `false` from async methods
- Example: [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart)

### Screen Navigation
- **Bottom Navigation:** [lib/screens/main_shell.dart](lib/screens/main_shell.dart) - 3 tabs (Discover, My Attempts, Profile)
- **Direct Navigation:** Use `Navigator.push()` with `MaterialPageRoute`
- **Auth Flow:** `main.dart` uses `Consumer<AuthProvider>` to show `LoginScreen` vs `MainShell`

## Development Workflows

### Running the App
```bash
flutter run                    # Hot reload enabled
flutter run -d chrome          # Web
flutter run -d android         # Android emulator
flutter run --release          # Release mode
```

### Code Generation (NOT USED)
This project uses **manual JSON parsing** - do NOT run `build_runner`:
```bash
# ❌ DON'T USE: flutter pub run build_runner build
```
The project includes `build_runner` in dev dependencies but doesn't use it. Models have manual `fromJson`/`toJson`.

### Common Issues
- **401 Unauthorized:** Check if token is set in `ApiClient` after login
- **Network errors:** Verify `baseUrl` in `api_client.dart` matches your backend
- **Provider not found:** Ensure provider registered in `main.dart` MultiProvider tree
- **Hot reload issues:** Full restart required after changing provider initialization

## Key Files Reference

| File | Purpose |
|------|---------|
| [lib/main.dart](lib/main.dart) | Provider setup, app entry point, auth routing |
| [lib/utils/api_client.dart](lib/utils/api_client.dart) | HTTP client with token management |
| [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart) | Auth state: login, register, logout, auto-login |
| [lib/providers/quiz_provider.dart](lib/providers/quiz_provider.dart) | Quiz list state and operations |
| [lib/services/attempt_service.dart](lib/services/attempt_service.dart) | Quiz attempt API calls (start, submit, results) |
| [lib/screens/main_shell.dart](lib/screens/main_shell.dart) | Bottom nav shell (3 tabs) |
| [lib/docs_ui/](lib/docs_ui/) | Detailed implementation guides (architecture, patterns, API integration) |

## Project-Specific Conventions

### Error Handling
Services throw `Exception(message)`, providers catch and set error state:
```dart
try {
  final result = await _service.doSomething();
  // handle success
} catch (e) {
  _setError(e.toString());
  return false;
}
```

### Logging
Use emoji-prefixed print statements for visibility:
```dart
print('🚀 Starting attempt for quiz $quizId');
print('✅ Attempt started successfully');
print('❌ Error: $error');
```

### State Management
- **Read once:** `context.read<Provider>()` - get provider without listening
- **Watch changes:** `Consumer<Provider>` or `context.watch<Provider>()` - rebuild on changes
- **Inside initState:** Always use `context.read`, never `context.watch`

## Backend Integration

- **API Base:** Configurable in `ApiClient` (currently local network IP)
- **Auth:** JWT Bearer tokens stored via `SharedPreferences` (see `auth_service.dart`)
- **Endpoints:** REST-style `/api/{resource}` paths
- **Response Format:** Backend returns PascalCase JSON matching C# conventions

## Adding New Features

1. **Model:** Create in `lib/models/`, add manual `fromJson`
2. **Service:** Add to `lib/services/` with `ApiClient` dependency
3. **Provider:** Create `ChangeNotifier` in `lib/providers/`
4. **Register:** Add to `main.dart` MultiProvider tree
5. **Screen:** Create in `lib/screens/`, consume via `Consumer<Provider>`

## Documentation

Extensive guides in [lib/docs_ui/](lib/docs_ui/):
- `getting-started.md` - Setup, dependencies
- `project-structure.md` - Detailed file organization
- `state-management.md` - Provider patterns and examples
- `api-integration.md` - HTTP client patterns
- `authentication.md` - Auth flow implementation
