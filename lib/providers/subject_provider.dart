import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class SubjectProvider extends ChangeNotifier {
  final SubjectService _subjectService;

  List<Subject> _subjects = [];
  SubjectDetail? _currentSubject;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Subject> get subjects => _subjects;
  SubjectDetail? get currentSubject => _currentSubject;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSubjects => _subjects.isNotEmpty;

  SubjectProvider(this._subjectService);

  /// Fetch all subjects
  Future<void> fetchSubjects() async {
    if (_isLoading) return; // Prevent duplicate calls
    
    _setLoading(true);
    
    try {
      _subjects = await _subjectService.getAllSubjects();
      _error = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Get subject by ID with courses
  Future<SubjectDetail?> getSubjectById(int id) async {
    _setLoading(true);
    
    try {
      _currentSubject = await _subjectService.getSubjectById(id);
      _error = null;
      _setLoading(false);
      return _currentSubject;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Create new subject (Admin only)
  Future<bool> createSubject(String name, String? description) async {
    _setLoading(true);
    
    try {
      final request = CreateSubjectRequest(
        name: name,
        description: description,
      );
      
      final newSubject = await _subjectService.createSubject(request);
      _subjects.add(newSubject);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Update subject (Admin only)
  Future<bool> updateSubject(int id, String name, String? description) async {
    _setLoading(true);
    
    try {
      final request = UpdateSubjectRequest(
        name: name,
        description: description,
      );
      
      final updatedSubject = await _subjectService.updateSubject(id, request);
      
      final index = _subjects.indexWhere((s) => s.id == id);
      if (index != -1) {
        _subjects[index] = updatedSubject;
      }
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Delete subject (Admin only)
  Future<bool> deleteSubject(int id) async {
    _setLoading(true);
    
    try {
      await _subjectService.deleteSubject(id);
      _subjects.removeWhere((s) => s.id == id);
      
      if (_currentSubject?.id == id) {
        _currentSubject = null;
      }
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Refresh subjects list
  Future<void> refresh() async {
    await fetchSubjects();
  }

  /// Clear current subject
  void clearCurrentSubject() {
    _currentSubject = null;
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
