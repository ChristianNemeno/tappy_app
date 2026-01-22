import 'package:flutter/material.dart';
import '../models/quiz/quiz.dart';
import '../models/quiz/quiz_detail.dart';
import '../services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  final QuizService _quizService;

  List<Quiz> _quizzes = [];
  List<Quiz> _myQuizzes = [];
  List<Quiz> _standaloneQuizzes = [];
  QuizDetail? _currentQuizDetail;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Quiz> get quizzes => _quizzes;
  List<Quiz> get myQuizzes => _myQuizzes;
  List<Quiz> get standaloneQuizzes => _standaloneQuizzes;
  QuizDetail? get currentQuizDetail => _currentQuizDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasQuizzes => _quizzes.isNotEmpty;

  QuizProvider(this._quizService);

  /// Fetch active quizzes
  Future<void> fetchActiveQuizzes() async {
    print('[INFO] QuizProvider: Starting to fetch active quizzes');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("[DEBUG] QuizProvider: Calling QuizService.getActiveQuizzes()");
      _quizzes = await _quizService.getActiveQuizzes();
      print('[SUCCESS] QuizProvider: Fetched ${_quizzes.length} active quizzes');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('[ERROR] QuizProvider: Failed to fetch quizzes - $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch standalone quizzes (not in units)
  Future<void> fetchStandaloneQuizzes() async {
    _setLoading(true);
    
    try {
      _standaloneQuizzes = await _quizService.getStandaloneQuizzes();
      _error = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Fetch quizzes created by current user
  Future<void> fetchMyQuizzes() async {
    _setLoading(true);
    
    try {
      _myQuizzes = await _quizService.getMyQuizzes();
      _error = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Get quiz with questions for taking
  Future<QuizDetail?> getQuizWithQuestions(int quizId) async {
    _setLoading(true);
    
    try {
      _currentQuizDetail = await _quizService.getQuizWithQuestions(quizId);
      _error = null;
      _setLoading(false);
      return _currentQuizDetail;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Create new quiz
  Future<bool> createQuiz(dynamic createQuizDto) async {
    _setLoading(true);
    
    try {
      await _quizService.createQuiz(createQuizDto);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Update quiz
  Future<bool> updateQuiz(int quizId, dynamic updateQuizDto) async {
    _setLoading(true);
    
    try {
      await _quizService.updateQuiz(quizId, updateQuizDto);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Delete quiz
  Future<bool> deleteQuiz(int quizId) async {
    _setLoading(true);
    
    try {
      await _quizService.deleteQuiz(quizId);
      
      // Remove from local lists
      _quizzes.removeWhere((q) => q.id == quizId);
      _myQuizzes.removeWhere((q) => q.id == quizId);
      _standaloneQuizzes.removeWhere((q) => q.id == quizId);
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Toggle quiz active status
  Future<bool> toggleQuizStatus(int quizId) async {
    _setLoading(true);
    
    try {
      await _quizService.toggleQuizStatus(quizId);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Assign quiz to unit
  Future<bool> assignQuizToUnit(int quizId, int unitId, int orderIndex) async {
    _setLoading(true);
    
    try {
      await _quizService.assignQuizToUnit(quizId, unitId, orderIndex);
      
      // Remove from standalone list if present
      _standaloneQuizzes.removeWhere((q) => q.id == quizId);
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Reorder quiz in unit
  Future<bool> reorderQuiz(int quizId, int newOrderIndex) async {
    _setLoading(true);
    
    try {
      await _quizService.reorderQuiz(quizId, newOrderIndex);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Clear current quiz detail
  void clearCurrentQuizDetail() {
    _currentQuizDetail = null;
    notifyListeners();
  }

  /// Refresh quizzes
  Future<void> refreshQuizzes() async {
    print('[INFO] QuizProvider: Refresh requested');
    await fetchActiveQuizzes();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _error = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}