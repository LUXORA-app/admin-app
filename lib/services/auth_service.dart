import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/auth_storage.dart';

class AuthService {
  const AuthService();

  /// Current authenticated user from `GET /api/user` (Sanctum).
  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in.');
    }
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}/user');
    late final http.Response response;
    try {
      response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } on http.ClientException catch (_) {
      throw Exception(_networkErrorMessage());
    } on SocketException catch (_) {
      throw Exception(_networkErrorMessage());
    }

    final data = _decodeJsonObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(data, response.statusCode));
    }
    return data;
  }

  /// Updates profile via `POST /api/user/profile` (multipart; avatar optional).
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? nationality,
    String? password,
    String? passwordConfirmation,
    File? avatarFile,
  }) async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in.');
    }

    final uri = Uri.parse('${ApiConfig.apiBaseUrl}/user/profile');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';

    if (name != null) {
      request.fields['name'] = name;
    }
    if (nationality != null) {
      request.fields['nationality'] = nationality;
    }
    if (password != null && password.isNotEmpty) {
      request.fields['password'] = password;
      request.fields['password_confirmation'] = passwordConfirmation ?? '';
    }
    if (avatarFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarFile.path),
      );
    }

    late final http.Response response;
    try {
      final streamed = await request.send();
      response = await http.Response.fromStream(streamed);
    } on http.ClientException catch (_) {
      throw Exception(_networkErrorMessage());
    } on SocketException catch (_) {
      throw Exception(_networkErrorMessage());
    }

    final data = _decodeJsonObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(data, response.statusCode));
    }

    final user = data['user'];
    if (user is Map<String, dynamic>) {
      return user;
    }
    return data;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}/login');
    late final http.Response response;
    try {
      response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
    } on http.ClientException catch (_) {
      throw Exception(_networkErrorMessage());
    } on SocketException catch (_) {
      throw Exception(_networkErrorMessage());
    }

    await _persistTokenFromResponse(response);
  }

  Future<void> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String adminSecret,
    String? nationality,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}/register');
    late final http.Response response;
    try {
      response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'nationality': nationality,
          'role': 'admin',
          'admin_secret': adminSecret,
        }),
      );
    } on http.ClientException catch (_) {
      throw Exception(_networkErrorMessage());
    } on SocketException catch (_) {
      throw Exception(_networkErrorMessage());
    }

    await _persistTokenFromResponse(response);
  }

  Future<void> logout() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      await AuthStorage.clearToken();
      return;
    }

    final uri = Uri.parse('${ApiConfig.apiBaseUrl}/logout');
    try {
      await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } finally {
      await AuthStorage.clearToken();
    }
  }

  Future<void> forgotPassword(String email) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}/forgot-password');
    late final http.Response response;
    try {
      response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );
    } on http.ClientException catch (_) {
      throw Exception(_networkErrorMessage());
    } on SocketException catch (_) {
      throw Exception(_networkErrorMessage());
    }

    final Map<String, dynamic> data = _decodeJsonObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(data, response.statusCode));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiBaseUrl}/reset-password');
    late final http.Response response;
    try {
      response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
    } on http.ClientException catch (_) {
      throw Exception(_networkErrorMessage());
    } on SocketException catch (_) {
      throw Exception(_networkErrorMessage());
    }

    final Map<String, dynamic> data = _decodeJsonObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(data, response.statusCode));
    }
  }

  Future<void> _persistTokenFromResponse(http.Response response) async {
    final Map<String, dynamic> data = _decodeJsonObject(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(data, response.statusCode));
    }

    final token = data['access_token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('Request succeeded but no access token was returned.');
    }

    await AuthStorage.saveToken(token);
  }

  Map<String, dynamic> _decodeJsonObject(String source) {
    if (source.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  String _extractErrorMessage(Map<String, dynamic> data, int statusCode) {
    if (data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }

    final errors = data['errors'];
    if (errors is Map<String, dynamic>) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
      }
    }

    return 'Request failed (HTTP $statusCode).';
  }

  String _networkErrorMessage() {
    return 'Unable to reach backend API. Check API_BASE_URL and backend server status.';
  }
}
