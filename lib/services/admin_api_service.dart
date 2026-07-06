import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/auth_storage.dart';

class AdminApiService {
  const AdminApiService();

  Future<List<Map<String, dynamic>>> getUsers() async {
    final res = await _get('/admin/users');
    final decoded = _decodeJson(res.body);
    if (decoded is List) {
      return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return const [];
  }

  Future<void> deleteUser(String id) async {
    await _delete('/admin/users/$id');
  }

  Future<void> blockUser(String id) async {
    await _post('/admin/users/$id/block', body: const {});
  }

  Future<void> unblockUser(String id) async {
    await _post('/admin/users/$id/unblock', body: const {});
  }

  Future<int> favoritesCount() async {
    final res = await _get('/admin/favorites/count');
    final decoded = _decodeJson(res.body);
    if (decoded is Map && decoded['count'] != null) {
      return int.tryParse(decoded['count'].toString()) ?? 0;
    }
    return 0;
  }

  Future<int> chatCount() async {
    final res = await _get('/admin/chat/count');
    final decoded = _decodeJson(res.body);
    if (decoded is Map && decoded['count'] != null) {
      return int.tryParse(decoded['count'].toString()) ?? 0;
    }
    return 0;
  }

  // Landmarks (admin can create/update/delete; listing is authenticated)
  Future<List<Map<String, dynamic>>> getLandmarks() async {
    final res = await _get('/landmarks');
    final decoded = _decodeJson(res.body);
    if (decoded is List) {
      return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>> createLandmark({
    required String name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    File? imageFile,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}/landmarks');
    final token = await AuthStorage.getToken();

    if (imageFile != null) {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['name'] = name;
      if (description != null) request.fields['description'] = description;
      if (location != null) request.fields['location'] = location;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      final streamedRes = await request.send();
      final res = await http.Response.fromStream(streamedRes);
      _throwIfNotOk(res);
      final decoded = _decodeJson(res.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{};
    }

    final res = await _post(
      '/landmarks',
      body: {
        'name': name,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'image_url': imageUrl,
      }..removeWhere((_, v) => v == null),
    );
    final decoded = _decodeJson(res.body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateLandmark(
    String id, {
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    File? imageFile,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}/landmarks/$id');
    final token = await AuthStorage.getToken();

    if (imageFile != null) {
      // Use POST directly for multipart updates as PHP does not populate $_FILES for PUT.
      // We added a POST route in the backend to handle this.
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      if (name != null) request.fields['name'] = name;
      if (description != null) request.fields['description'] = description;
      if (location != null) request.fields['location'] = location;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      final streamedRes = await request.send();
      final res = await http.Response.fromStream(streamedRes);
      _throwIfNotOk(res);
      final decoded = _decodeJson(res.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{};
    }

    final res = await _put(
      '/landmarks/$id',
      body: {
        'name': name,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'image_url': imageUrl,
      }..removeWhere((_, v) => v == null),
    );
    final decoded = _decodeJson(res.body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{};
  }

  Future<void> deleteLandmark(String id) async {
    await _delete('/landmarks/$id');
  }

  Future<http.Response> _get(String path) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    try {
      final token = await AuthStorage.getToken();
      final res = await http.get(
        uri,
        headers: _headers(token: token),
      );
      _throwIfNotOk(res);
      return res;
    } on http.ClientException catch (_) {
      throw Exception(_networkErrorMessage());
    } on SocketException catch (_) {
      throw Exception(_networkErrorMessage());
    }
  }

  Future<http.Response> _post(String path, {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    try {
      final token = await AuthStorage.getToken();
      final res = await http.post(
        uri,
        headers: _headers(token: token),
        body: jsonEncode(body),
      );
      _throwIfNotOk(res);
      return res;
    } on http.ClientException catch (_) {
      throw Exception(_networkErrorMessage());
    } on SocketException catch (_) {
      throw Exception(_networkErrorMessage());
    }
  }

  Future<http.Response> _put(String path, {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    try {
      final token = await AuthStorage.getToken();
      final res = await http.put(
        uri,
        headers: _headers(token: token),
        body: jsonEncode(body),
      );
      _throwIfNotOk(res);
      return res;
    } on http.ClientException catch (_) {
      throw Exception(_networkErrorMessage());
    } on SocketException catch (_) {
      throw Exception(_networkErrorMessage());
    }
  }

  Future<http.Response> _delete(String path) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}$path');
    try {
      final token = await AuthStorage.getToken();
      final res = await http.delete(
        uri,
        headers: _headers(token: token),
      );
      _throwIfNotOk(res);
      return res;
    } on http.ClientException catch (_) {
      throw Exception(_networkErrorMessage());
    } on SocketException catch (_) {
      throw Exception(_networkErrorMessage());
    }
  }

  Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _throwIfNotOk(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    final decoded = _decodeJson(res.body);
    if (decoded is Map) {
      final msg = decoded['message']?.toString();
      if (msg != null && msg.isNotEmpty) {
        throw Exception(msg);
      }
      final errors = decoded['errors'];
      if (errors is Map) {
        for (final v in errors.values) {
          if (v is List && v.isNotEmpty) {
            throw Exception(v.first.toString());
          }
        }
      }
    }
    throw Exception('Request failed (HTTP ${res.statusCode}).');
  }

  dynamic _decodeJson(String source) {
    final s = source.trim();
    if (s.isEmpty) return null;
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
  }

  String _networkErrorMessage() {
    return 'Unable to reach backend API. Check API_BASE_URL and backend server status.';
  }
}

