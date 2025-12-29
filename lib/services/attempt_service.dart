// lib/services/attempt_service.dart
import 'dart:convert';
import '../models/quiz_attempt.dart';
import '../models/submit_attempt_request.dart';
import '../models/submit_answer.dart';
import '../models/attempt_result.dart';
import '../models/leaderboard_entry.dart';
import '../utils/api_client.dart';

class AttemptService {
  final ApiClient _apiClient;

  AttemptService(this._apiClient);

  /// POST /api/quiz-attempt/start
  Future<QuizAttempt> startAttempt(int quizId) async {
    print('🚀 Starting attempt for quiz $quizId');
    
    final response = await _apiClient.post('/quiz-attempt/start', {
      'quizId': quizId,
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ Attempt started successfully');
      return QuizAttempt.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to start quiz');
    } else {
      throw Exception('Failed to start quiz attempt');
    }
  }

  /// POST /api/quiz-attempt/submit
  Future<AttemptResult> submitAttempt(
    int quizAttemptId,
    Map<int, int> answers,
  ) async {
    print('📤 Submitting attempt $quizAttemptId with ${answers.length} answers');
    
    final submitAnswers = answers.entries
        .map((e) => SubmitAnswer(questionId: e.key, choiceId: e.value))
        .toList();

    final request = SubmitAttemptRequest(
      quizAttemptId: quizAttemptId,
      answers: submitAnswers,
    );

    final response = await _apiClient.post(
      '/quiz-attempt/submit',
      request.toJson(),
    );

    if (response.statusCode == 200) {
      print('✅ Attempt submitted successfully');
      return AttemptResult.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to submit attempt');
    } else {
      throw Exception('Failed to submit attempt');
    }
  }

  /// GET /api/quiz-attempt/{id}
  Future<QuizAttempt> getAttempt(int attemptId) async {
    final response = await _apiClient.get('/quiz-attempt/$attemptId');

    if (response.statusCode == 200) {
      return QuizAttempt.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Attempt not found');
    } else {
      throw Exception('Failed to load attempt');
    }
  }

  /// GET /api/quiz-attempt/{id}/result
  Future<AttemptResult> getAttemptResult(int attemptId) async {
    final response = await _apiClient.get('/quiz-attempt/$attemptId/result');

    if (response.statusCode == 200) {
      return AttemptResult.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Result not found');
    } else {
      throw Exception('Failed to load result');
    }
  }

  /// GET /api/quiz-attempt/user/me
  Future<List<QuizAttempt>> getUserAttempts() async {
    final response = await _apiClient.get('/quiz-attempt/user/me');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => QuizAttempt.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user attempts');
    }
  }

  /// GET /api/quiz-attempt/quiz/{quizId}/leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard(int quizId, {int topCount = 10}) async {
    print('📊 Fetching leaderboard for quiz $quizId (top $topCount)');
    
    final response = await _apiClient.get(
      '/quiz-attempt/quiz/$quizId/leaderboard?topCount=$topCount',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LeaderboardEntry.fromJson(json)).toList();
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Invalid request');
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }
}