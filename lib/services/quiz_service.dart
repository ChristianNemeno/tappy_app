import 'dart:convert';
import '../models/quiz.dart';
import '../models/quiz_detail.dart';
import '../models/create_quiz_dto.dart';
import '../models/create_question_dto.dart';
import '../models/update_quiz_dto.dart';
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

  /// Get quizzes created by current user
  Future<List<Quiz>> getMyQuizzes() async {
    print('📚 Fetching user\'s quizzes');
    
    final response = await _apiClient.get('/quiz/user/me');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Quiz.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load your quizzes');
    }
  }

  /// POST /api/quiz - Create new quiz with questions
  Future<Quiz> createQuiz(CreateQuizDto dto) async {
    print('🆕 Creating quiz: ${dto.title}');
    
    final response = await _apiClient.post('/quiz', dto.toJson());

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ Quiz created successfully');
      return Quiz.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Validation failed');
    } else {
      throw Exception('Failed to create quiz');
    }
  }

  /// POST /api/quiz/{id}/questions - Add question to existing quiz
  Future<void> addQuestion(int quizId, CreateQuestionDto dto) async {
    print('➕ Adding question to quiz $quizId');
    
    final response = await _apiClient.post(
      '/quiz/$quizId/questions',
      dto.toJson(),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ Question added successfully');
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Validation failed');
    } else if (response.statusCode == 404) {
      throw Exception('Quiz not found');
    } else if (response.statusCode == 403) {
      throw Exception('You can only add questions to your own quizzes');
    } else {
      throw Exception('Failed to add question');
    }
  }

  /// PUT /api/quiz/{id} - Update quiz metadata
  Future<Quiz> updateQuiz(int id, UpdateQuizDto dto) async {
    print('📝 Updating quiz $id');
    
    final response = await _apiClient.put('/quiz/$id', dto.toJson());

    if (response.statusCode == 200) {
      print('✅ Quiz updated successfully');
      return Quiz.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Validation failed');
    } else if (response.statusCode == 404) {
      throw Exception('Quiz not found');
    } else if (response.statusCode == 403) {
      throw Exception('You can only update your own quizzes');
    } else {
      throw Exception('Failed to update quiz');
    }
  }

  /// DELETE /api/quiz/{id} - Delete quiz
  Future<void> deleteQuiz(int id) async {
    print('🗑️ Deleting quiz $id');
    
    final response = await _apiClient.delete('/quiz/$id');

    if (response.statusCode == 204 || response.statusCode == 200) {
      print('✅ Quiz deleted successfully');
    } else if (response.statusCode == 404) {
      throw Exception('Quiz not found');
    } else if (response.statusCode == 403) {
      throw Exception('You can only delete your own quizzes');
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Cannot delete quiz');
    } else {
      throw Exception('Failed to delete quiz');
    }
  }

  /// PATCH /api/quiz/{id}/toggle - Toggle quiz active status
  Future<Quiz> toggleQuizStatus(int id) async {
    print('🔄 Toggling quiz $id status');
    
    final response = await _apiClient.patch('/quiz/$id/toggle', {});

    if (response.statusCode == 200) {
      print('✅ Quiz status toggled successfully');
      return Quiz.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Quiz not found');
    } else if (response.statusCode == 403) {
      throw Exception('You can only toggle your own quizzes');
    } else {
      throw Exception('Failed to toggle quiz status');
    }
  }
}