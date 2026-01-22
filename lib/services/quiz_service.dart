import 'dart:convert';
import '../models/quiz/quiz.dart';
import '../models/quiz/quiz_detail.dart';
import '../models/quiz/create_quiz_dto.dart';
import '../models/quiz/create_question_dto.dart';
import '../models/quiz/update_quiz_dto.dart';
import '../utils/api_client.dart';

class QuizService {
  final ApiClient _apiClient;

  QuizService(this._apiClient);

  Future<List<Quiz>> getActiveQuizzes() async {
    final response = await _apiClient.get('/quiz/active');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('[INFO] QuizService: Retrieved ${data.length} active quizzes');
      print('[DEBUG] QuizService: Response data - ${response.body}');
      return data.map((json) => Quiz.fromJson(json)).toList();
    } else {
      print('[ERROR] QuizService: Failed to fetch active quizzes - ${response.statusCode}');
      print('[ERROR] Response body: ${response.body}');
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
  Future<void> toggleQuizStatus(int id) async {
    print('🔄 Toggling quiz $id status');
    
    final response = await _apiClient.patch('/quiz/$id/toggle');

    if (response.statusCode == 200) {
      print('✅ Quiz status toggled successfully');
    } else if (response.statusCode == 404) {
      throw Exception('Quiz not found');
    } else if (response.statusCode == 403) {
      throw Exception('You can only toggle your own quizzes');
    } else {
      throw Exception('Failed to toggle quiz status');
    }
  }

  /// GET /api/quiz/standalone - Get standalone quizzes (not assigned to unit)
  Future<List<Quiz>> getStandaloneQuizzes() async {
    final response = await _apiClient.get('/quiz/standalone');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Quiz.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load standalone quizzes');
    }
  }

  /// GET /api/quiz?unitId={id} - Get quizzes by unit
  Future<List<Quiz>> getQuizzesByUnit(int unitId) async {
    final response = await _apiClient.get('/quiz?unitId=$unitId');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Quiz.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quizzes for unit');
    }
  }

  /// PATCH /api/quiz/{id}/assign-unit - Assign quiz to unit
  Future<Quiz> assignQuizToUnit(int quizId, int unitId, int orderIndex) async {
    print('📌 Assigning quiz $quizId to unit $unitId');
    
    final response = await _apiClient.patch(
      '/quiz/$quizId/assign-unit',
      {
        'unitId': unitId,
        'orderIndex': orderIndex,
      },
    );

    if (response.statusCode == 200) {
      print('✅ Quiz assigned to unit successfully');
      return Quiz.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to assign quiz to unit');
    } else if (response.statusCode == 403) {
      throw Exception('You do not have permission to assign this quiz');
    } else if (response.statusCode == 404) {
      throw Exception('Quiz or unit not found');
    } else {
      throw Exception('Failed to assign quiz to unit');
    }
  }

  /// PATCH /api/quiz/{id}/reorder - Reorder quiz in unit
  Future<Quiz> reorderQuiz(int quizId, int newOrderIndex) async {
    print('🔢 Reordering quiz $quizId to position $newOrderIndex');
    
    final response = await _apiClient.patch(
      '/quiz/$quizId/reorder',
      {'orderIndex': newOrderIndex},
    );

    if (response.statusCode == 200) {
      print('✅ Quiz reordered successfully');
      return Quiz.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to reorder quiz');
    } else if (response.statusCode == 403) {
      throw Exception('You do not have permission to reorder this quiz');
    } else if (response.statusCode == 404) {
      throw Exception('Quiz not found');
    } else {
      throw Exception('Failed to reorder quiz');
    }
  }
}