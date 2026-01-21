import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class CourseProvider extends ChangeNotifier {
  final CourseService _courseService;

  List<Course> _courses = [];
  CourseDetail? _currentCourse;
  Map<int, List<Course>> _coursesBySubject = {}; // Cache courses by subject
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Course> get courses => _courses;
  CourseDetail? get currentCourse => _currentCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCourses => _courses.isNotEmpty;

  CourseProvider(this._courseService);

  /// Fetch all courses
  Future<void> fetchAllCourses() async {
    if (_isLoading) return;
    
    _setLoading(true);
    
    try {
      _courses = await _courseService.getAllCourses();
      _error = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Get courses by subject
  Future<List<Course>> getCoursesBySubject(int subjectId, {bool forceRefresh = false}) async {
    // Return cached if available and not forcing refresh
    if (!forceRefresh && _coursesBySubject.containsKey(subjectId)) {
      return _coursesBySubject[subjectId]!;
    }
    
    _setLoading(true);
    
    try {
      final courses = await _courseService.getCoursesBySubject(subjectId);
      _coursesBySubject[subjectId] = courses;
      _error = null;
      _setLoading(false);
      return courses;
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Get course by ID with units
  Future<CourseDetail?> getCourseById(int id) async {
    _setLoading(true);
    
    try {
      _currentCourse = await _courseService.getCourseById(id);
      _error = null;
      _setLoading(false);
      return _currentCourse;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Create new course
  Future<bool> createCourse(String title, String? description, int subjectId) async {
    _setLoading(true);
    
    try {
      final request = CreateCourseRequest(
        title: title,
        description: description,
        subjectId: subjectId,
      );
      
      final newCourse = await _courseService.createCourse(request);
      _courses.add(newCourse);
      
      // Invalidate subject cache
      _coursesBySubject.remove(subjectId);
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Update course
  Future<bool> updateCourse(int id, String title, String? description, int subjectId) async {
    _setLoading(true);
    
    try {
      final request = UpdateCourseRequest(
        title: title,
        description: description,
        subjectId: subjectId,
      );
      
      final updatedCourse = await _courseService.updateCourse(id, request);
      
      final index = _courses.indexWhere((c) => c.id == id);
      if (index != -1) {
        final oldSubjectId = _courses[index].subjectId;
        _courses[index] = updatedCourse;
        
        // Invalidate cache for both old and new subjects
        _coursesBySubject.remove(oldSubjectId);
        _coursesBySubject.remove(subjectId);
      }
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Delete course
  Future<bool> deleteCourse(int id) async {
    _setLoading(true);
    
    try {
      await _courseService.deleteCourse(id);
      
      final course = _courses.firstWhere((c) => c.id == id);
      _courses.removeWhere((c) => c.id == id);
      
      // Invalidate subject cache
      _coursesBySubject.remove(course.subjectId);
      
      if (_currentCourse?.id == id) {
        _currentCourse = null;
      }
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Clear current course
  void clearCurrentCourse() {
    _currentCourse = null;
    notifyListeners();
  }

  /// Clear cache
  void clearCache() {
    _coursesBySubject.clear();
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
