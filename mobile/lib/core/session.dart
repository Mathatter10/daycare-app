import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum Role { caregiver, parent }

class AppUser {
  const AppUser({required this.id, required this.email, required this.fullName, required this.role, this.phone});

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final Role role;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'] as String,
    email: j['email'] as String,
    fullName: j['full_name'] as String,
    phone: j['phone'] as String?,
    role: j['role'] == 'parent' ? Role.parent : Role.caregiver,
  );

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'full_name': fullName, 'phone': phone, 'role': role.name};
}

class Tokens {
  const Tokens(this.access, this.refresh);
  final String access;
  final String refresh;
}

class StoredSession {
  const StoredSession(this.user, this.tokens);
  final AppUser user;
  final Tokens tokens;
}

/// Keeps tokens in the platform keystore (docs/SECURITY.md), never in Isar.
class AuthStore {
  AuthStore([FlutterSecureStorage? storage]) : _s = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _s;
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUser = 'user';

  String? _accessCache;

  Future<StoredSession?> load() async {
    final values = await _s.readAll();
    final access = values[_kAccess], refresh = values[_kRefresh], user = values[_kUser];
    if (access == null || refresh == null || user == null) return null;
    _accessCache = access;
    return StoredSession(AppUser.fromJson(jsonDecode(user) as Map<String, dynamic>), Tokens(access, refresh));
  }

  Future<void> save(AppUser user, Tokens tokens) async {
    _accessCache = tokens.access;
    await _s.write(key: _kAccess, value: tokens.access);
    await _s.write(key: _kRefresh, value: tokens.refresh);
    await _s.write(key: _kUser, value: jsonEncode(user.toJson()));
  }

  Future<void> saveTokens(Tokens tokens) async {
    _accessCache = tokens.access;
    await _s.write(key: _kAccess, value: tokens.access);
    await _s.write(key: _kRefresh, value: tokens.refresh);
  }

  Future<String?> accessToken() async => _accessCache ??= await _s.read(key: _kAccess);

  Future<String?> refreshToken() => _s.read(key: _kRefresh);

  Future<void> clear() async {
    _accessCache = null;
    await _s.deleteAll();
  }
}
