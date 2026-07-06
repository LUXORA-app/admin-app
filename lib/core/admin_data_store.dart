import 'dart:io';
import 'package:flutter/foundation.dart';

import '../services/admin_api_service.dart';
import '../services/auth_service.dart';

class AdminUser {
  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.blocked = false,
    required this.createdAt,
  });

  final String id;
  String name;
  String email;
  bool blocked;
  final DateTime createdAt;
}

class Landmark {
  Landmark({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.photoUrl,
  });

  final String id;
  String name;
  String description;
  double lat;
  double lng;
  String photoUrl;
}

class AdminDataStore extends ChangeNotifier {
  AdminDataStore({AdminApiService? api}) : _api = api ?? const AdminApiService();

  final AdminApiService _api;

  final List<AdminUser> _users = [];
  final List<Landmark> _landmarks = [];
  Map<String, dynamic>? _currentUser;

  List<AdminUser> get users => List.unmodifiable(_users);
  List<Landmark> get landmarks => List.unmodifiable(_landmarks);
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isCurrentUserAdmin => _currentUser?['role']?.toString() == 'admin';

  set currentUser(Map<String, dynamic>? user) {
    _currentUser = user;
    notifyListeners();
  }

  int get userCount => _users.length;
  int get landmarkCount => _landmarks.length;

  bool _loadingUsers = false;
  bool _loadingLandmarks = false;
  String? _lastError;

  bool get loadingUsers => _loadingUsers;
  bool get loadingLandmarks => _loadingLandmarks;
  String? get lastError => _lastError;

  List<AdminUser> get recentUsers {
    final sorted = [..._users]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  List<AdminUser> searchUsers(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_users);
    return _users
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> fetchCurrentUser() async {
    try {
      final authService = AuthService();
      _currentUser = await authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    _lastError = null;
    notifyListeners();
    try {
      await Future.wait([
        fetchUsers(),
        fetchLandmarks(),
      ]);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    if (_loadingUsers) return;
    _loadingUsers = true;
    _lastError = null;
    notifyListeners();

    try {
      final raw = await _api.getUsers();
      final parsed = raw.map(_userFromJson).toList();
      _users
        ..clear()
        ..addAll(parsed);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> fetchLandmarks() async {
    if (_loadingLandmarks) return;
    _loadingLandmarks = true;
    _lastError = null;
    notifyListeners();

    try {
      final raw = await _api.getLandmarks();
      final parsed = raw.map(_landmarkFromJson).toList();
      _landmarks
        ..clear()
        ..addAll(parsed);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loadingLandmarks = false;
      notifyListeners();
    }
  }

  void updateUser(AdminUser user, {String? name, String? email}) {
    if (name != null) user.name = name;
    if (email != null) user.email = email;
    notifyListeners();
  }

  Future<void> deleteUser(AdminUser user) async {
    _lastError = null;
    notifyListeners();
    try {
      await _api.deleteUser(user.id);
      _users.removeWhere((u) => u.id == user.id);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> setUserBlocked(AdminUser user, bool blocked) async {
    _lastError = null;
    notifyListeners();
    try {
      if (blocked) {
        await _api.blockUser(user.id);
      } else {
        await _api.unblockUser(user.id);
      }
      user.blocked = blocked;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> addLandmark({
    required String name,
    required String description,
    required double lat,
    required double lng,
    String? photoUrl,
    File? imageFile,
  }) async {
    _lastError = null;
    notifyListeners();
    try {
      final created = await _api.createLandmark(
        name: name,
        description: description,
        latitude: lat,
        longitude: lng,
        imageUrl: photoUrl,
        imageFile: imageFile,
      );
      _landmarks.insert(0, _landmarkFromJson(created));
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateLandmark(
    Landmark lm, {
    String? name,
    String? description,
    double? lat,
    double? lng,
    String? photoUrl,
    File? imageFile,
  }) {
    _lastError = null;
    notifyListeners();
    return _api
        .updateLandmark(
          lm.id,
          name: name,
          description: description,
          latitude: lat,
          longitude: lng,
          imageUrl: photoUrl,
          imageFile: imageFile,
        )
        .then((updated) {
          final fresh = _landmarkFromJson(updated);
          lm.name = fresh.name;
          lm.description = fresh.description;
          lm.lat = fresh.lat;
          lm.lng = fresh.lng;
          lm.photoUrl = fresh.photoUrl;
        })
        .catchError((e) {
          _lastError = e.toString().replaceFirst('Exception: ', '');
          throw e;
        })
        .whenComplete(notifyListeners);
  }

  Future<void> deleteLandmark(Landmark lm) async {
    _lastError = null;
    notifyListeners();
    try {
      await _api.deleteLandmark(lm.id);
      _landmarks.removeWhere((x) => x.id == lm.id);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  AdminUser _userFromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final role = json['role']?.toString() ?? 'user';
    final createdAtRaw = json['created_at']?.toString();
    final createdAt = DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
    return AdminUser(
      id: id,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      blocked: role == 'blocked',
      createdAt: createdAt,
    );
  }

  Landmark _landmarkFromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final lat = double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0;
    final lng = double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0;
    return Landmark(
      id: id,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      lat: lat,
      lng: lng,
      photoUrl: json['image_url']?.toString() ?? '',
    );
  }
}
