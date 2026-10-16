import 'package:dio/dio.dart';

import '../config.dart';
import 'session.dart';

/// An API failure translated for the UI. [status] is null for network
/// problems (offline, timeout, DNS).
class ApiException implements Exception {
  ApiException(this.message, {this.status});

  final String message;
  final int? status;

  bool get isNetwork => status == null;

  /// Worth retrying later: offline, server trouble, rate limit, or an
  /// expired session that a new login will fix.
  bool get isRetryable => isNetwork || status == 401 || status == 408 || status == 429 || (status ?? 0) >= 500;

  factory ApiException.from(Object e) {
    if (e is ApiException) return e;
    if (e is DioException) {
      final res = e.response;
      if (res == null) {
        return ApiException('Tidak ada koneksi ke server. Data akan dikirim saat online.');
      }
      final data = res.data;
      final msg = data is Map && data['error'] is String ? data['error'] as String : 'Server error ${res.statusCode}';
      return ApiException(msg, status: res.statusCode);
    }
    return ApiException(e.toString());
  }

  @override
  String toString() => 'ApiException($status): $message';
}

class LoginResult {
  const LoginResult(this.user, this.tokens);
  final AppUser user;
  final Tokens tokens;
}

/// JSON client for /api/v1. Adds the access token to every request and,
/// on 401, refreshes it once (rotating refresh token) and retries.
class ApiClient {
  ApiClient({required AuthStore store, required void Function() onSessionExpired})
    // ignore: prefer_initializing_formals
    : _store = store,
      // ignore: prefer_initializing_formals
      _onSessionExpired = onSessionExpired {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _store.accessToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (err, handler) async {
          final req = err.requestOptions;
          if (err.response?.statusCode != 401 || req.extra['retried'] == true) {
            return handler.next(err);
          }
          try {
            // Requests queued behind a refresh may already carry a stale token.
            final current = await _store.accessToken();
            final sent = (req.headers['Authorization'] as String?)?.replaceFirst('Bearer ', '');
            if (current == null || current == sent) {
              await _refresh();
            }
            final token = await _store.accessToken();
            req.headers['Authorization'] = 'Bearer $token';
            req.extra['retried'] = true;
            handler.resolve(await _dio.fetch(req));
          } catch (_) {
            _onSessionExpired();
            handler.next(err);
          }
        },
      ),
    );
  }

  final AuthStore _store;
  final void Function() _onSessionExpired;

  static BaseOptions _options() => BaseOptions(
    baseUrl: '$apiBaseUrl/api/v1',
    // Render's free tier can take ~1 minute to wake up.
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(minutes: 2),
    contentType: Headers.jsonContentType,
  );

  final Dio _dio = Dio(_options());
  final Dio _raw = Dio(_options()); // no auth interceptor (login/refresh)

  Future<void> _refresh() async {
    final refresh = await _store.refreshToken();
    if (refresh == null) throw ApiException('Sesi berakhir', status: 401);
    final res = await _raw.post<Map<String, dynamic>>('/auth/refresh', data: {'refresh_token': refresh});
    await _store.saveTokens(_tokensFrom(res.data!));
  }

  Tokens _tokensFrom(Map<String, dynamic> j) => Tokens(j['access_token'] as String, j['refresh_token'] as String);

  Future<T> _call<T>(Future<Response<T>> Function() fn) async {
    try {
      return (await fn()).data as T;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  // --- auth ---------------------------------------------------------------

  Future<LoginResult> login(String email, String password) async {
    try {
      final res = await _raw.post<Map<String, dynamic>>('/auth/login', data: {'email': email, 'password': password});
      final j = res.data!;
      return LoginResult(AppUser.fromJson(j['user'] as Map<String, dynamic>), _tokensFrom(j));
    } catch (e) {
      final ex = ApiException.from(e);
      throw switch (ex.status) {
        401 => ApiException('Email atau kata sandi salah.', status: 401),
        403 => ApiException('Akun admin hanya bisa masuk lewat web admin.', status: 403),
        429 => ApiException('Terlalu banyak percobaan. Coba lagi 15 menit lagi.', status: 429),
        null => ApiException('Tidak bisa terhubung ke server. Periksa koneksi internet.'),
        _ => ex,
      };
    }
  }

  Future<void> logout() async {
    final refresh = await _store.refreshToken();
    if (refresh == null) return;
    try {
      await _raw.post<void>('/auth/logout', data: {'refresh_token': refresh});
    } catch (_) {
      // Best effort: local sign-out happens regardless.
    }
  }

  // --- sync & reads -------------------------------------------------------

  Future<Map<String, dynamic>> sync({String? activitiesCursor, String? attendanceCursor}) => _call(
    () => _dio.get<Map<String, dynamic>>(
      '/sync',
      queryParameters: {'activities_cursor': ?activitiesCursor, 'attendance_cursor': ?attendanceCursor},
    ),
  );

  Future<Map<String, dynamic>> timeline(String childId, String date) =>
      _call(() => _dio.get<Map<String, dynamic>>('/children/$childId/timeline', queryParameters: {'date': date}));

  // --- writes (sent from the outbox) --------------------------------------

  Future<Map<String, dynamic>> checkIn(Map<String, dynamic> body) =>
      _call(() => _dio.post<Map<String, dynamic>>('/attendance/check-in', data: body));

  Future<Map<String, dynamic>> checkOut(Map<String, dynamic> body) =>
      _call(() => _dio.post<Map<String, dynamic>>('/attendance/check-out', data: body));

  Future<Map<String, dynamic>> putActivity(String id, Map<String, dynamic> body) =>
      _call(() => _dio.put<Map<String, dynamic>>('/activities/$id', data: body));

  Future<void> deleteActivity(String id) => _call(() => _dio.delete<void>('/activities/$id'));

  Future<Map<String, dynamic>> uploadPhoto({
    required String mediaId,
    required String childId,
    required String path,
    required String takenAt,
    String? activityId,
  }) async {
    final form = FormData.fromMap({
      'child_id': childId,
      'taken_at': takenAt,
      'activity_id': ?activityId,
      'file': await MultipartFile.fromFile(path, filename: '$mediaId.jpg', contentType: DioMediaType('image', 'jpeg')),
    });
    return _call(() => _dio.put<Map<String, dynamic>>('/media/$mediaId/photo', data: form));
  }
}
