import 'dart:convert';
import '../models/models.dart';
import '../utils/api_client.dart';

class UnitService {
  final ApiClient _apiClient;

  UnitService(this._apiClient);

  /// GET /api/unit/{id} - Get unit with quizzes
  Future<UnitDetail> getUnitById(int id) async {
    final response = await _apiClient.get('/unit/$id');

    if (response.statusCode == 200) {
      return UnitDetail.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Unit not found');
    } else {
      throw Exception('Failed to load unit details');
    }
  }

  /// GET /api/unit/course/{courseId} - Get units by course (ordered)
  Future<List<Unit>> getUnitsByCourse(int courseId) async {
    final response = await _apiClient.get('/unit/course/$courseId');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Unit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load units for course');
    }
  }

  /// GET /api/unit/{unitId}/quizzes - Get quizzes by unit (ordered)
  Future<List<Quiz>> getQuizzesByUnit(int unitId) async {
    final response = await _apiClient.get('/unit/$unitId/quizzes');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Quiz.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quizzes for unit');
    }
  }

  /// POST /api/unit - Create unit
  Future<Unit> createUnit(CreateUnitRequest request) async {
    final response = await _apiClient.post('/unit', request.toJson());

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Unit.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to create unit');
    } else {
      throw Exception('Failed to create unit');
    }
  }

  /// PUT /api/unit/{id} - Update unit (Owner only)
  Future<Unit> updateUnit(int id, UpdateUnitRequest request) async {
    final response = await _apiClient.put('/unit/$id', request.toJson());

    if (response.statusCode == 200) {
      return Unit.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to update unit');
    } else if (response.statusCode == 403) {
      throw Exception('You do not have permission to update this unit');
    } else if (response.statusCode == 404) {
      throw Exception('Unit not found');
    } else {
      throw Exception('Failed to update unit');
    }
  }

  /// PATCH /api/unit/{id}/reorder - Reorder unit (Owner only)
  Future<Unit> reorderUnit(int id, int newOrderIndex) async {
    final request = ReorderUnitRequest(orderIndex: newOrderIndex);
    final response = await _apiClient.patch('/unit/$id/reorder', request.toJson());

    if (response.statusCode == 200) {
      return Unit.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to reorder unit');
    } else if (response.statusCode == 403) {
      throw Exception('You do not have permission to reorder this unit');
    } else if (response.statusCode == 404) {
      throw Exception('Unit not found');
    } else {
      throw Exception('Failed to reorder unit');
    }
  }

  /// DELETE /api/unit/{id} - Delete unit (Owner only)
  Future<void> deleteUnit(int id) async {
    final response = await _apiClient.delete('/unit/$id');

    if (response.statusCode == 204) {
      return; // Success
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Cannot delete unit');
    } else if (response.statusCode == 403) {
      throw Exception('You do not have permission to delete this unit');
    } else if (response.statusCode == 404) {
      throw Exception('Unit not found');
    } else {
      throw Exception('Failed to delete unit');
    }
  }
}
