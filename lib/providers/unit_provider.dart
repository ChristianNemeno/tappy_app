import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class UnitProvider extends ChangeNotifier {
  final UnitService _unitService;

  UnitDetail? _currentUnit;
  Map<int, List<Unit>> _unitsByCourse = {}; // Cache units by course
  Map<int, List<Quiz>> _quizzesByUnit = {}; // Cache quizzes by unit
  bool _isLoading = false;
  String? _error;

  // Getters
  UnitDetail? get currentUnit => _currentUnit;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UnitProvider(this._unitService);

  /// Get units by course
  Future<List<Unit>> getUnitsByCourse(int courseId, {bool forceRefresh = false}) async {
    // Return cached if available and not forcing refresh
    if (!forceRefresh && _unitsByCourse.containsKey(courseId)) {
      return _unitsByCourse[courseId]!;
    }
    
    _setLoading(true);
    
    try {
      final units = await _unitService.getUnitsByCourse(courseId);
      _unitsByCourse[courseId] = units;
      _error = null;
      _setLoading(false);
      return units;
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Get unit by ID with quizzes
  Future<UnitDetail?> getUnitById(int id) async {
    _setLoading(true);
    
    try {
      _currentUnit = await _unitService.getUnitById(id);
      _error = null;
      _setLoading(false);
      return _currentUnit;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Get quizzes by unit
  Future<List<Quiz>> getQuizzesByUnit(int unitId, {bool forceRefresh = false}) async {
    // Return cached if available and not forcing refresh
    if (!forceRefresh && _quizzesByUnit.containsKey(unitId)) {
      return _quizzesByUnit[unitId]!;
    }
    
    _setLoading(true);
    
    try {
      final quizzes = await _unitService.getQuizzesByUnit(unitId);
      _quizzesByUnit[unitId] = quizzes;
      _error = null;
      _setLoading(false);
      return quizzes;
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Create new unit
  Future<bool> createUnit(String title, int orderIndex, int courseId) async {
    _setLoading(true);
    
    try {
      final request = CreateUnitRequest(
        title: title,
        orderIndex: orderIndex,
        courseId: courseId,
      );
      
      await _unitService.createUnit(request);
      
      // Invalidate course cache
      _unitsByCourse.remove(courseId);
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Update unit
  Future<bool> updateUnit(int id, String title, int orderIndex, int courseId) async {
    _setLoading(true);
    
    try {
      final request = UpdateUnitRequest(
        title: title,
        orderIndex: orderIndex,
        courseId: courseId,
      );
      
      await _unitService.updateUnit(id, request);
      
      // Invalidate course cache
      _unitsByCourse.remove(courseId);
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Reorder unit
  Future<bool> reorderUnit(int id, int courseId, int newOrderIndex) async {
    _setLoading(true);
    
    try {
      await _unitService.reorderUnit(id, newOrderIndex);
      
      // Invalidate course cache
      _unitsByCourse.remove(courseId);
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Delete unit
  Future<bool> deleteUnit(int id, int courseId) async {
    _setLoading(true);
    
    try {
      await _unitService.deleteUnit(id);
      
      // Invalidate caches
      _unitsByCourse.remove(courseId);
      _quizzesByUnit.remove(id);
      
      if (_currentUnit?.id == id) {
        _currentUnit = null;
      }
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Clear current unit
  void clearCurrentUnit() {
    _currentUnit = null;
    notifyListeners();
  }

  /// Clear all caches
  void clearCache() {
    _unitsByCourse.clear();
    _quizzesByUnit.clear();
    notifyListeners();
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
