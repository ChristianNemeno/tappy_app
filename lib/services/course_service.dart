import 'dart:convert';
import '../models/models.dart';
import '../utils/api_client.dart';

class CourseService {
  final ApiClient _apiClient;

  CourseService(this._apiClient);

  /// GET /api/course - Get all courses
  Future<List<Course>> getAllCourses() async {
    final response = await _apiClient.get('/course');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  /// GET /api/course/{id} - Get course with units
  Future<CourseDetail> getCourseById(int id) async {
    final response = await _apiClient.get('/course/$id');

    if (response.statusCode == 200) {
      return CourseDetail.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Course not found');
    } else {
      throw Exception('Failed to load course details');
    }
  }

  /// GET /api/course/subject/{subjectId} - Get courses by subject
  Future<List<Course>> getCoursesBySubject(int subjectId) async {
    final response = await _apiClient.get('/course/subject/$subjectId');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load courses for subject');
    }
  }

  /// POST /api/course - Create course
  Future<Course> createCourse(CreateCourseRequest request) async {
    final response = await _apiClient.post('/course', request.toJson());

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Course.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to create course');
    } else {
      throw Exception('Failed to create course');
    }
  }

  /// PUT /api/course/{id} - Update course (Owner only)
  Future<Course> updateCourse(int id, UpdateCourseRequest request) async {
    final response = await _apiClient.put('/course/$id', request.toJson());

    if (response.statusCode == 200) {
      return Course.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to update course');
    } else if (response.statusCode == 403) {
      throw Exception('You do not have permission to update this course');
    } else if (response.statusCode == 404) {
      throw Exception('Course not found');
    } else {
      throw Exception('Failed to update course');
    }
  }

  /// DELETE /api/course/{id} - Delete course (Owner only)
  Future<void> deleteCourse(int id) async {
    final response = await _apiClient.delete('/course/$id');

    if (response.statusCode == 204) {
      return; // Success
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Cannot delete course');
    } else if (response.statusCode == 403) {
      throw Exception('You do not have permission to delete this course');
    } else if (response.statusCode == 404) {
      throw Exception('Course not found');
    } else {
      throw Exception('Failed to delete course');
    }
  }
}
