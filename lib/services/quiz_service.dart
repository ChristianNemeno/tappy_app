import 'dart:convert';
import '../models/quiz.dart';
import '../models/quiz_detail.dart';
import '../utils/api_client.dart';

class QuizService {
  final ApiClient _apiClient;

  QuizService(this._apiClient);

  Future<List<Quiz>> getActiveQuizzes() async {
    final response = await _apiClient.get('/quiz/active');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Quiz.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  Future<Quiz> getQuizById(int id) async {
    final response = await _apiClient.get('/quiz/$id');

    if (response.statusCode == 200) {
      return Quiz.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Quiz not found');
    } else {
      throw Exception('Failed to load quiz details');
    }
  }

  /// Get quiz details with questions for taking the quiz
  Future<QuizDetail> getQuizWithQuestions(int id) async {
    final response = await _apiClient.get('/quiz/$id');

    if (response.statusCode == 200) {
      return QuizDetail.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Quiz not found');
    } else {
      throw Exception('Failed to load quiz details');
    }
  }
}