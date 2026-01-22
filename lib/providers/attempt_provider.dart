import 'package:flutter/material.dart';
import '../models/attempt/quiz_attempt.dart';
import '../models/attempt/attempt_result.dart';
import '../models/quiz/question.dart';
import '../models/attempt/leaderboard_entry.dart';
import '../services/attempt_service.dart';
import 'dart:developer' as developer;

class AttemptProvider extends ChangeNotifier {
  final AttemptService _attemptService;

  QuizAttempt? _currentAttempt;
  List<Question>? _questions;
  Map<int, int> _answers = {}; // questionId -> choiceId
  AttemptResult? _lastResult;
  List<QuizAttempt> _userAttempts = [];
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  QuizAttempt? get currentAttempt => _currentAttempt;
  List<Question>? get questions => _questions;
  Map<int, int> get answers => Map.unmodifiable(_answers);
  AttemptResult? get lastResult => _lastResult;
  List<QuizAttempt> get userAttempts => _userAttempts;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Validation getters
  bool get hasCurrentAttempt => _currentAttempt != null;
  bool get hasQuestions => _questions != null && _questions!.isNotEmpty;
  int get totalQuestions => _questions?.length ?? 0;
  int get answeredCount => _answers.length;
  bool get isComplete => hasQuestions && _answers.length == totalQuestions;
  double get progress => hasQuestions ? answeredCount / totalQuestions : 0.0;

  AttemptProvider(this._attemptService);

  /// Start a new quiz attempt
  Future<bool> startAttempt(int quizId, List<Question> questions) async {
    _setLoading(true);
    _log('🚀 Starting attempt for quiz $quizId');

    try {
      final attempt = await _attemptService.startAttempt(quizId);
      _currentAttempt = attempt;
      _questions = questions;
      _answers = {}; // Reset answers for new attempt
      _lastResult = null;
      _error = null;
      
      _log('✅ Attempt started: ID ${attempt.id}');
      _setLoading(false);
      return true;
    } catch (e) {
      _log('❌ Failed to start attempt', error: e);
      _setError(e.toString());
      return false;
    }
  }

  /// Set answer for a specific question
  void setAnswer(int questionId, int choiceId) {
    if (!hasCurrentAttempt) {
      _log('⚠️ Cannot set answer: No active attempt');
      return;
    }

    if (_questions?.any((q) => q.id == questionId) != true) {
      _log('⚠️ Invalid question ID: $questionId');
      return;
    }

    _answers[questionId] = choiceId;
    _log('📝 Answer set: Q$questionId -> C$choiceId (${answeredCount}/$totalQuestions)');
    notifyListeners();
  }

  /// Get answer for a specific question
  int? getAnswer(int questionId) {
    return _answers[questionId];
  }

  /// Clear answer for a specific question
  void clearAnswer(int questionId) {
    if (_answers.remove(questionId) != null) {
      _log('🗑️ Answer cleared for question $questionId');
      notifyListeners();
    }
  }

  /// Check if a specific question is answered
  bool isQuestionAnswered(int questionId) {
    return _answers.containsKey(questionId);
  }

  /// Get list of unanswered question numbers (1-indexed)
  List<int> getUnansweredQuestions() {
    if (!hasQuestions) return [];
    
    return _questions!
        .asMap()
        .entries
        .where((entry) => !_answers.containsKey(entry.value.id))
        .map((entry) => entry.key + 1) // Convert to 1-indexed
        .toList();
  }

  /// Validate completion before submission
  String? validateCompletion() {
    if (!hasCurrentAttempt) {
      return 'No active attempt';
    }

    if (!hasQuestions) {
      return 'No questions loaded';
    }

    if (!isComplete) {
      final unanswered = getUnansweredQuestions();
      if (unanswered.length == 1) {
        return 'Question ${unanswered.first} is not answered';
      } else {
        return '${unanswered.length} questions not answered: ${unanswered.take(3).join(", ")}${unanswered.length > 3 ? "..." : ""}';
      }
    }

    return null; // Valid
  }

  /// Submit the current attempt
  Future<bool> submitAttempt() async {
    // Validate before submission
    final validationError = validateCompletion();
    if (validationError != null) {
      _setError(validationError);
      _log('❌ Validation failed: $validationError');
      return false;
    }

    _setLoading(true);
    _log('📤 Submitting attempt ${_currentAttempt!.id}');

    try {
      final result = await _attemptService.submitAttempt(
        _currentAttempt!.id,
        _answers,
      );
      
      _lastResult = result;
      _log('✅ Attempt submitted successfully - Score: ${result.score}');
      
      // Clear current attempt state after successful submission
      _currentAttempt = null;
      _questions = null;
      _answers = {};
      _error = null;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _log('❌ Failed to submit attempt', error: e);
      _setError(e.toString());
      return false;
    }
  }

  /// Reset attempt state (call when abandoning an attempt)
  void resetAttempt() {
    _log('🔄 Resetting attempt state');
    _currentAttempt = null;
    _questions = null;
    _answers = {};
    _lastResult = null;
    _error = null;
    notifyListeners();
  }

  /// Clear last result (call when navigating away from result screen)
  void clearLastResult() {
    _lastResult = null;
    notifyListeners();
  }

  /// Fetch user's attempt history
  Future<void> fetchUserAttempts() async {
    _setLoading(true);
    
    try {
      _userAttempts = await _attemptService.getUserAttempts();
      _error = null;
      _setLoading(false);
    } catch (e) {
      _log('❌ Failed to fetch user attempts', error: e);
      _setError(e.toString());
    }
  }

  /// Fetch leaderboard for a quiz
  Future<void> fetchLeaderboard(int quizId, {int topCount = 10}) async {
    _setLoading(true);
    
    try {
      _leaderboard = await _attemptService.getLeaderboard(quizId, topCount: topCount);
      _error = null;
      _setLoading(false);
    } catch (e) {
      _log('❌ Failed to fetch leaderboard', error: e);
      _setError(e.toString());
    }
  }

  /// Get attempt result by ID
  Future<AttemptResult?> getAttemptResult(int attemptId) async {
    _setLoading(true);
    
    try {
      final result = await _attemptService.getAttemptResult(attemptId);
      _error = null;
      _setLoading(false);
      return result;
    } catch (e) {
      _log('❌ Failed to fetch attempt result', error: e);
      _setError(e.toString());
      return null;
    }
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'AttemptProvider',
      error: error,
      stackTrace: stackTrace,
    );
  }
}