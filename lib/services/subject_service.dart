import 'dart:convert';
import '../models/models.dart';
import '../utils/api_client.dart';

class SubjectService {
  final ApiClient _apiClient;

  SubjectService(this._apiClient);

  /// GET /api/subject - Get all subjects
  Future<List<Subject>> getAllSubjects() async {
    final response = await _apiClient.get('/subject');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Subject.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  /// GET /api/subject/{id} - Get subject with courses
  Future<SubjectDetail> getSubjectById(int id) async {
    final response = await _apiClient.get('/subject/$id');

    if (response.statusCode == 200) {
      return SubjectDetail.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Subject not found');
    } else {
      throw Exception('Failed to load subject details');
    }
  }

  /// POST /api/subject - Create subject (Admin only)
  Future<Subject> createSubject(CreateSubjectRequest request) async {
    final response = await _apiClient.post('/subject', request.toJson());

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Subject.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to create subject');
    } else if (response.statusCode == 403) {
      throw Exception('Admin access required');
    } else {
      throw Exception('Failed to create subject');
    }
  }

  /// PUT /api/subject/{id} - Update subject (Admin only)
  Future<Subject> updateSubject(int id, UpdateSubjectRequest request) async {
    final response = await _apiClient.put('/subject/$id', request.toJson());

    if (response.statusCode == 200) {
      return Subject.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to update subject');
    } else if (response.statusCode == 403) {
      throw Exception('Admin access required');
    } else if (response.statusCode == 404) {
      throw Exception('Subject not found');
    } else {
      throw Exception('Failed to update subject');
    }
  }

  /// DELETE /api/subject/{id} - Delete subject (Admin only)
  Future<void> deleteSubject(int id) async {
    final response = await _apiClient.delete('/subject/$id');

    if (response.statusCode == 204) {
      return; // Success
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Cannot delete subject');
    } else if (response.statusCode == 403) {
      throw Exception('Admin access required');
    } else if (response.statusCode == 404) {
      throw Exception('Subject not found');
    } else {
      throw Exception('Failed to delete subject');
    }
  }
}
