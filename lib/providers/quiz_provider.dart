import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  final QuizService _quizService;

  List<Quiz> _quizzes = [];
  bool _isLoading = false;
  String? _error;

  /**
   * Getters for quizzes, loading state, and error message.
   */
  List<Quiz> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  QuizProvider(this._quizService);

  /**
   * Fetches the list of active quizzes from the 
   * QuizService and updates the state accordingly.
   */
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

  /** Refreshes the list of active quizzes 
   * by re-fetching them from the QuizService. */
  Future<void> refreshQuizzes() async {
    print('[INFO] QuizProvider: Refresh requested');
    await fetchActiveQuizzes();
  }
}