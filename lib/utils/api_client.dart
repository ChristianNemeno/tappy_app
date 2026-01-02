
import 'package:http/http.dart' as http;
import 'dart:convert';


class ApiClient {
  
  //static const String baseUrl = 'https://localhost:7237/api';

  final baseUrl = 'http://10.0.2.2:5080/api';

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> _headers(){
      final headers = {
        'Content-Type': 'application/json',
      };

      if(_token != null){
        headers['Authorization'] = 'Bearer $_token';
      }

      return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      return await http.get(uri, headers: _headers()).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout - unable to reach server');
        },
      );
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      return await http.post(
        uri,
        headers: _headers(),
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout - unable to reach server');
        },
      );
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      return await http.put(
        uri,
        headers: _headers(),
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout - unable to reach server');
        },
      );
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      return await http.delete(uri, headers: _headers()).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout - unable to reach server');
        },
      );
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<http.Response> patch(String endpoint, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      return await http.patch(
        uri,
        headers: _headers(),
        body: body != null ? json.encode(body) : null,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout - unable to reach server');
        },
      );
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

}

