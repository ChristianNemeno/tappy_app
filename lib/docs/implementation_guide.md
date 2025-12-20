# TAPCET Mobile App Implementation Guide

## Table of Contents
1. [Overview](#overview)
2. [Flutter UI Architecture](#flutter-ui-architecture)
3. [Widget Lifecycle](#widget-lifecycle)
4. [API Integration](#api-integration)
5. [Authentication Flow](#authentication-flow)
6. [State Management](#state-management)
7. [Implementation Roadmap](#implementation-roadmap)
8. [Code Examples](#code-examples)

---

## Overview

This guide explains how to implement the TAPCET quiz mobile app using Flutter, connecting it to the TAPCET Quiz API backend. The app follows a clean architecture pattern with clear separation of concerns.

### Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: ASP.NET Core 8 Web API
- **Authentication**: JWT (JSON Web Tokens)
- **State Management**: Provider (recommended) or Riverpod
- **HTTP Client**: http or dio package

### Core Features
- User authentication (register/login)
- Quiz discovery and browsing
- Quiz taking with timed attempts
- Results and detailed review
- Leaderboard
- Quiz creation and management

---

## Flutter UI Architecture

### App Structure

```
lib/
├── main.dart                    # Entry point
├── models/                      # Data models
│   ├── user.dart
│   ├── quiz.dart
│   ├── question.dart
│   ├── choice.dart
│   ├── attempt.dart
│   └── attempt_result.dart
├── services/                    # API services
│   ├── auth_service.dart
│   ├── quiz_service.dart
│   └── attempt_service.dart
├── providers/                   # State management
│   ├── auth_provider.dart
│   ├── quiz_provider.dart
│   └── attempt_provider.dart
├── screens/                     # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── discover/
│   │   ├── discover_screen.dart
│   │   └── quiz_detail_screen.dart
│   ├── quiz/
│   │   ├── quiz_taking_screen.dart
│   │   └── quiz_result_screen.dart
│   ├── attempts/
│   │   └── attempt_history_screen.dart
│   ├── creator/
│   │   ├── my_quizzes_screen.dart
│   │   ├── create_quiz_screen.dart
│   │   └── add_questions_screen.dart
│   └── leaderboard/
│       └── leaderboard_screen.dart
├── widgets/                     # Reusable widgets
│   ├── quiz_card.dart
│   ├── question_card.dart
│   └── loading_indicator.dart
└── utils/                       # Utilities
    ├── constants.dart
    ├── api_client.dart
    └── validators.dart
```

### Layer Responsibilities

#### 1. Models Layer
- Define data structures matching backend DTOs
- Handle JSON serialization/deserialization
- Immutable data classes using `final` fields

#### 2. Services Layer
- Handle all HTTP requests to backend API
- Manage JWT token inclusion in headers
- Parse responses and handle errors
- Return models or throw exceptions

#### 3. Providers Layer (State Management)
- Hold application state
- Notify listeners of state changes
- Coordinate between UI and services
- Handle loading and error states

#### 4. Screens Layer
- Render UI based on state
- Handle user interactions
- Navigate between screens
- Display loading and error states

#### 5. Widgets Layer
- Reusable UI components
- Accept data via constructors
- Emit events via callbacks

---

## Widget Lifecycle

### StatelessWidget vs StatefulWidget

**Use StatelessWidget when:**
- Widget doesn't need to maintain state
- Data comes from parent or providers
- No animations or controllers needed

Example: Quiz cards, static text displays

**Use StatefulWidget when:**
- Need to manage local UI state (e.g., form inputs)
- Using TextEditingControllers
- Managing animations or timers
- Handling disposable resources

Example: Login screen, quiz taking screen

### StatefulWidget Lifecycle

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // 1. Constructor (implicit)
  // State object is created
  
  // 2. initState()
  @override
  void initState() {
    super.initState();
    // Called once when widget is inserted into tree
    // Initialize controllers, start timers, fetch data
    _controller = TextEditingController();
    _loadData();
  }
  
  // 3. didChangeDependencies()
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Called after initState and when inherited widgets change
    // Access InheritedWidget or Provider here
  }
  
  // 4. build()
  @override
  Widget build(BuildContext context) {
    // Called on every rebuild
    // Return widget tree
    return Container();
  }
  
  // 5. didUpdateWidget()
  @override
  void didUpdateWidget(MyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Called when parent rebuilds with new configuration
    // Compare widget.property with oldWidget.property
  }
  
  // 6. setState()
  void _updateState() {
    setState(() {
      // Modify state variables
      // Triggers rebuild
    });
  }
  
  // 7. deactivate()
  @override
  void deactivate() {
    // Called when widget is removed from tree temporarily
    super.deactivate();
  }
  
  // 8. dispose()
  @override
  void dispose() {
    // Called when widget is removed permanently
    // Clean up: dispose controllers, cancel timers, close streams
    _controller.dispose();
    super.dispose();
  }
}
```

### Best Practices

1. **Always dispose resources**: Controllers, timers, streams
2. **Avoid heavy work in build()**: It's called frequently
3. **Use const constructors**: When widgets are static
4. **Extract widgets**: Break down large build methods
5. **Handle async operations properly**: Use FutureBuilder or state

---

## API Integration

### Backend API Overview

**Base URL**: `https://localhost:7237` (development)

#### Authentication
- All protected endpoints require: `Authorization: Bearer <jwt-token>`
- Token expires after 60 minutes
- JWT contains: userId, email, roles

### Setting Up HTTP Client

```dart
// lib/utils/api_client.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  static const String baseUrl = 'https://localhost:7237/api';
  
  String? _token;
  
  void setToken(String token) {
    _token = token;
  }
  
  void clearToken() {
    _token = null;
  }
  
  Map<String, String> _headers() {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }
  
  Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.get(uri, headers: _headers());
  }
  
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      uri,
      headers: _headers(),
      body: json.encode(body),
    );
  }
  
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      uri,
      headers: _headers(),
      body: json.encode(body),
    );
  }
  
  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.delete(uri, headers: _headers());
  }
  
  Future<http.Response> patch(String endpoint, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.patch(
      uri,
      headers: _headers(),
      body: body != null ? json.encode(body) : null,
    );
  }
}
```

### Key API Endpoints

#### Authentication

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/auth/register` | POST | No | Register new user |
| `/auth/login` | POST | No | Login and get JWT |
| `/auth/check-email` | POST | No | Check email availability |

#### Quiz Management

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/quiz` | GET | No | Get all quizzes |
| `/quiz/active` | GET | No | Get active quizzes |
| `/quiz/{id}` | GET | No | Get quiz details |
| `/quiz` | POST | Yes | Create quiz |
| `/quiz/{id}` | PUT | Yes | Update quiz (owner) |
| `/quiz/{id}` | DELETE | Yes | Delete quiz (owner) |
| `/quiz/{id}/toggle` | PATCH | Yes | Toggle active status |
| `/quiz/{id}/questions` | POST | Yes | Add question to quiz |

#### Quiz Attempts

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/quiz-attempt/start` | POST | Yes | Start quiz attempt |
| `/quiz-attempt/submit` | POST | Yes | Submit answers |
| `/quiz-attempt/{id}` | GET | Yes | Get attempt details |
| `/quiz-attempt/{id}/result` | GET | Yes | Get attempt results |
| `/quiz-attempt/user/me` | GET | Yes | Get user's attempts |
| `/quiz-attempt/quiz/{quizId}` | GET | Yes | Get quiz attempts |
| `/quiz-attempt/quiz/{quizId}/leaderboard` | GET | Yes | Get leaderboard |

---

## Authentication Flow

### Registration Flow

```
User                    App                     API                     Database
 |                       |                       |                         |
 |--Enter credentials--->|                       |                         |
 |                       |--Validate input------>|                         |
 |                       |                       |--Check email---------->|
 |                       |                       |<---Email available-----|
 |                       |                       |--Create user---------->|
 |                       |                       |--Hash password-------->|
 |                       |                       |<---User created--------|
 |                       |<--JWT token-----------|                         |
 |<--Navigate to home----|                       |                         |
```

### Login Flow

```
User                    App                     API                     Database
 |                       |                       |                         |
 |--Enter credentials--->|                       |                         |
 |                       |--POST /auth/login---->|                         |
 |                       |                       |--Query user----------->|
 |                       |                       |<---User data-----------|
 |                       |                       |--Verify password------>|
 |                       |                       |<---Password valid------|
 |                       |                       |--Generate JWT--------->|
 |                       |<--JWT + expiresAt-----|                         |
 |                       |--Store token--------->|                         |
 |<--Navigate to home----|                       |                         |
```

### Protected Request Flow

```
User                    App                     API                     Middleware
 |                       |                       |                         |
 |--Request resource---->|                       |                         |
 |                       |--GET with token------>|                         |
 |                       |                       |--Validate JWT---------->|
 |                       |                       |<---Claims---------------|
 |                       |                       |--Process request------->|
 |                       |<--Resource data-------|                         |
 |<--Display data--------|                       |                         |
```

### Token Expiry Handling

```dart
// lib/services/auth_service.dart
class AuthService {
  final ApiClient _client;
  DateTime? _tokenExpiry;
  
  bool isTokenValid() {
    if (_tokenExpiry == null) return false;
    return DateTime.now().isBefore(_tokenExpiry!);
  }
  
  Future<void> refreshIfNeeded() async {
    if (!isTokenValid()) {
      // Navigate to login
      throw Exception('Token expired');
    }
  }
}
```

---

## State Management

### Using Provider Pattern

```dart
// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  AuthProvider(this._authService);
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _authService.login(email, password);
      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _authService.register(username, email, password);
      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void logout() {
    _user = null;
    _authService.clearToken();
    notifyListeners();
  }
}
```

### Setting Up Providers in Main

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        ChangeNotifierProxyProvider<AuthProvider, QuizProvider>(
          create: (context) => QuizProvider(
            context.read<QuizService>(),
          ),
          update: (_, auth, previous) => previous ?? QuizProvider(
            context.read<QuizService>(),
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
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isAuthenticated 
            ? const MainScreen() 
            : const LoginScreen();
        },
      ),
    );
  }
}
```

---

## Implementation Roadmap

### Phase 1: Core Authentication (Week 1)

#### Tasks
1. **Setup project structure**
   - Create folders: models, services, providers, screens
   - Add dependencies: http, provider, shared_preferences

2. **Implement models**
   - `User`: id, username, email, token, expiresAt, roles
   - `AuthResponse`: user, token, expiresAt

3. **Implement AuthService**
   - `register()` → POST /api/auth/register
   - `login()` → POST /api/auth/login
   - `checkEmail()` → POST /api/auth/check-email
   - Token storage using SharedPreferences

4. **Implement AuthProvider**
   - Login state management
   - Registration state management
   - Auto-login from stored token

5. **Build UI screens**
   - Enhance LoginScreen with provider integration
   - Enhance RegisterScreen with provider integration
   - Add loading indicators and error handling

#### Acceptance Criteria
- User can register with validation
- User can login and receive JWT
- Token is stored locally
- App auto-logs in on restart if token valid
- Errors are displayed clearly

---

### Phase 2: Quiz Discovery (Week 2)

#### Tasks
1. **Implement models**
   - `Quiz`: id, title, description, createdBy, isActive, questionCount
   - `QuizDetail`: Quiz + questions + choices

2. **Implement QuizService**
   - `getActiveQuizzes()` → GET /api/quiz/active
   - `getQuizById(id)` → GET /api/quiz/{id}
   - Include JWT in headers

3. **Implement QuizProvider**
   - Fetch and cache active quizzes
   - Handle refresh
   - Search/filter functionality

4. **Build UI screens**
   - DiscoverScreen: list of quiz cards
   - QuizDetailScreen: show quiz info + start button
   - Quiz card widget

#### Acceptance Criteria
- User can browse active quizzes
- User can view quiz details
- Loading states handled
- Pull-to-refresh works

---

### Phase 3: Quiz Taking (Week 3)

#### Tasks
1. **Implement models**
   - `Question`: id, text, explanation, imageUrl, choices
   - `Choice`: id, text
   - `QuizAttempt`: id, quizId, startedAt
   - `SubmitAnswer`: questionId, choiceId

2. **Implement AttemptService**
   - `startAttempt(quizId)` → POST /api/quiz-attempt/start
   - `submitAttempt(attemptId, answers)` → POST /api/quiz-attempt/submit

3. **Implement AttemptProvider**
   - Manage current attempt state
   - Track selected answers
   - Validate completion before submit

4. **Build UI screens**
   - QuizTakingScreen: question navigation, choice selection
   - Progress indicator (question X of Y)
   - Submit confirmation dialog

#### Acceptance Criteria
- User can answer questions
- Navigation between questions works
- Can't submit until all answered
- Submit sends correct payload
- Loading during submission

---

### Phase 4: Results & Review (Week 4)

#### Tasks
1. **Implement models**
   - `AttemptResult`: attemptId, score, correctCount, items
   - `AttemptResultItem`: question, userChoice, correctChoice, explanation

2. **Implement AttemptService**
   - `getAttemptResult(attemptId)` → GET /api/quiz-attempt/{id}/result

3. **Build UI screens**
   - ResultSummaryScreen: score, statistics, actions
   - DetailedReviewScreen: question-by-question breakdown
   - Highlight correct/incorrect

#### Acceptance Criteria
- User sees score immediately after submit
- Can view detailed review
- Correct answers highlighted in green
- Incorrect answers highlighted in red
- Explanations displayed

---

### Phase 5: History & Leaderboard (Week 5)

#### Tasks
1. **Implement models**
   - `AttemptSummary`: attemptId, quizTitle, score, completedAt
   - `LeaderboardEntry`: rank, username, score, completionTime

2. **Implement AttemptService**
   - `getUserAttempts()` → GET /api/quiz-attempt/user/me
   - `getLeaderboard(quizId)` → GET /api/quiz-attempt/quiz/{quizId}/leaderboard

3. **Build UI screens**
   - AttemptHistoryScreen: list of past attempts
   - LeaderboardScreen: ranked list

#### Acceptance Criteria
- User can view all past attempts
- Leaderboard shows top performers
- Current user highlighted in leaderboard
- Can tap attempt to view results

---

### Phase 6: Quiz Creation (Week 6)

#### Tasks
1. **Implement models**
   - `CreateQuizDto`: title, description, questions
   - `CreateQuestionDto`: text, explanation, choices
   - `CreateChoiceDto`: text, isCorrect

2. **Implement QuizService**
   - `createQuiz(dto)` → POST /api/quiz
   - `addQuestion(quizId, dto)` → POST /api/quiz/{id}/questions
   - `updateQuiz(id, dto)` → PUT /api/quiz/{id}
   - `deleteQuiz(id)` → DELETE /api/quiz/{id}
   - `toggleQuiz(id)` → PATCH /api/quiz/{id}/toggle

3. **Build UI screens**
   - MyQuizzesScreen: list of created quizzes
   - CreateQuizScreen: title + description form
   - AddQuestionsScreen: dynamic question/choice builder
   - EditQuizScreen

#### Acceptance Criteria
- User can create quiz with metadata
- Can add multiple questions
- Each question has 2-6 choices
- Exactly one choice marked correct
- Can edit/delete own quizzes
- Can toggle active status

---

## Code Examples

### Complete Auth Service

```dart
// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/api_client.dart';

class AuthService {
  final ApiClient _client;
  static const String _tokenKey = 'auth_token';
  static const String _expiryKey = 'token_expiry';
  
  AuthService(this._client);
  
  Future<AuthResponse> register(String username, String email, String password) async {
    final response = await _client.post('/auth/register', {
      'userName': username,
      'email': email,
      'password': password,
      'confirmPassword': password,
    });
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data['token'], data['expiresAt']);
      _client.setToken(data['token']);
      return AuthResponse.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Registration failed');
    }
  }
  
  Future<AuthResponse> login(String email, String password) async {
    final response = await _client.post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data['token'], data['expiresAt']);
      _client.setToken(data['token']);
      return AuthResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid email or password');
    } else {
      throw Exception('Login failed');
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
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isBefore(expiry)) {
        _client.setToken(token);
        return token;
      }
    }
    return null;
  }
  
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
    _client.clearToken();
  }
}

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

### Complete Quiz Taking Screen

```dart
// lib/screens/quiz/quiz_taking_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/question.dart';
import '../../providers/attempt_provider.dart';

class QuizTakingScreen extends StatefulWidget {
  final int attemptId;
  final List<Question> questions;
  
  const QuizTakingScreen({
    Key? key,
    required this.attemptId,
    required this.questions,
  }) : super(key: key);
  
  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};
  
  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];
    final isLastQuestion = _currentIndex == widget.questions.length - 1;
    final allAnswered = _answers.length == widget.questions.length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1} of ${widget.questions.length}'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.questions.length,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (question.imageUrl != null) ...[
                    const SizedBox(height: 16),
                    Image.network(
                      question.imageUrl!,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ...question.choices.map((choice) {
                    final isSelected = _answers[question.id] == choice.id;
                    return Card(
                      color: isSelected ? Colors.blue.shade50 : null,
                      child: RadioListTile<int>(
                        title: Text(choice.text),
                        value: choice.id,
                        groupValue: _answers[question.id],
                        onChanged: (value) {
                          setState(() {
                            _answers[question.id] = value!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex--;
                        });
                      },
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLastQuestion
                        ? (allAnswered ? () => _submitQuiz(context) : null)
                        : () {
                            setState(() {
                              _currentIndex++;
                            });
                          },
                    child: Text(isLastQuestion ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _submitQuiz(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Quiz'),
        content: const Text('Are you sure you want to submit? You cannot change answers after submission.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    final provider = context.read<AttemptProvider>();
    final success = await provider.submitAttempt(widget.attemptId, _answers);
    
    if (success && mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/result',
        arguments: widget.attemptId,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to submit')),
      );
    }
  }
}
```

### Complete Model with JSON Serialization

```dart
// lib/models/quiz.dart
class Quiz {
  final int id;
  final String title;
  final String description;
  final String createdByName;
  final bool isActive;
  final int questionCount;
  final DateTime createdAt;
  
  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.createdByName,
    required this.isActive,
    required this.questionCount,
    required this.createdAt,
  });
  
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      createdByName: json['createdByName'] ?? 'Unknown',
      isActive: json['isActive'] ?? true,
      questionCount: json['questionCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdByName': createdByName,
      'isActive': isActive,
      'questionCount': questionCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
```

---

## Best Practices

### Error Handling

```dart
try {
  final result = await service.fetchData();
  setState(() {
    _data = result;
  });
} on UnauthorizedException {
  // Token expired, navigate to login
  Navigator.pushReplacementNamed(context, '/login');
} on NetworkException catch (e) {
  _showError('Network error: ${e.message}');
} catch (e) {
  _showError('An unexpected error occurred');
}
```

### Loading States

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _buildContent(),
    );
  }
}
```

### Form Validation

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (value.length < 3) {
            return 'Must be at least 3 characters';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process data
          }
        },
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

---

## Testing Strategy

### Unit Tests
- Test models: JSON serialization/deserialization
- Test services: Mock HTTP responses
- Test validators: Input validation logic

### Widget Tests
- Test UI components in isolation
- Test user interactions
- Verify state changes

### Integration Tests
- Test complete flows end-to-end
- Test navigation
- Test API integration with test backend

---

## Deployment Checklist

- [ ] Update API base URL for production
- [ ] Enable HTTPS certificate validation
- [ ] Remove debug prints
- [ ] Add error tracking (Sentry, Firebase Crashlytics)
- [ ] Add analytics
- [ ] Test on real devices
- [ ] Optimize images and assets
- [ ] Configure app icons and splash screen
- [ ] Test offline behavior
- [ ] Implement token refresh mechanism
- [ ] Add rate limiting handling
- [ ] Test with slow network

---

## Resources

### Documentation
- Flutter docs: https://docs.flutter.dev
- Provider package: https://pub.dev/packages/provider
- HTTP package: https://pub.dev/packages/http
- Backend API docs: See `docs/` in tapcet-api repository

### Repository
- Backend API: https://github.com/ChristianNemeno/tapcet-api

---

## Conclusion

This guide provides a comprehensive roadmap for implementing the TAPCET mobile app. Follow the phases sequentially, test thoroughly at each stage, and maintain clean architecture principles throughout development. The backend API is well-documented and follows RESTful conventions, making integration straightforward.

For questions or issues, refer to the backend API documentation in the `docs/` directory of the tapcet-api repository.
