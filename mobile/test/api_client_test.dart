import 'dart:convert';
import 'dart:typed_data';

import 'package:daycare_app/core/api_client.dart';
import 'package:daycare_app/core/session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers each request path from [routes]; a null answer is a network
/// failure (no response), like being offline.
class FakeAdapter implements HttpClientAdapter {
  final routes = <String, ({int status, Map<String, dynamic> body})? Function()>{};
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final path = options.uri.path.replaceFirst('/api/v1', '');
    paths.add(path);
    final answer = routes[path]?.call();
    if (answer == null) {
      throw DioException.connectionError(requestOptions: options, reason: 'offline');
    }
    return ResponseBody.fromString(
      jsonEncode(answer.body),
      answer.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAdapter http;
  late AuthStore store;
  late int expired;
  late ApiClient api;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    store = AuthStore();
    await store.saveTokens(const Tokens('old-access', 'old-refresh'));
    http = FakeAdapter();
    expired = 0;
    api = ApiClient(store: store, onSessionExpired: () => expired++, adapter: http);
  });

  const unauthorized = (status: 401, body: <String, dynamic>{'error': 'unauthorized'});
  const ok = (status: 200, body: <String, dynamic>{'children': []});
  const newTokens = (status: 200, body: <String, dynamic>{'access_token': 'new-access', 'refresh_token': 'new-refresh'});

  test('refresh then retry on 401', () async {
    var first = true;
    http.routes['/sync'] = () {
      if (first) {
        first = false;
        return unauthorized;
      }
      return ok;
    };
    http.routes['/auth/refresh'] = () => newTokens;

    await api.sync();

    expect(http.paths, ['/sync', '/auth/refresh', '/sync']);
    expect(await store.accessToken(), 'new-access');
    expect(expired, 0);
  });

  test('refresh refused by the server ends the session', () async {
    http.routes['/sync'] = () => unauthorized;
    http.routes['/auth/refresh'] = () => unauthorized;

    await expectLater(api.sync(), throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)));
    expect(expired, 1);
  });

  test('refresh failing offline keeps the session', () async {
    http.routes['/sync'] = () => unauthorized;
    http.routes['/auth/refresh'] = () => null;

    final err = await api.sync().then<ApiException?>((_) => null, onError: (Object e) => e as ApiException);
    expect(err?.isRetryable, isTrue);
    expect(expired, 0);
    expect(await store.refreshToken(), 'old-refresh');
  });

  test('refresh failing with a server error keeps the session', () async {
    http.routes['/sync'] = () => unauthorized;
    http.routes['/auth/refresh'] = () => (status: 503, body: <String, dynamic>{'error': 'waking up'});

    await expectLater(api.sync(), throwsA(isA<ApiException>()));
    expect(expired, 0);
  });

  test('retry failing offline after a good refresh keeps the session', () async {
    var first = true;
    http.routes['/sync'] = () {
      if (first) {
        first = false;
        return unauthorized;
      }
      return null;
    };
    http.routes['/auth/refresh'] = () => newTokens;

    await expectLater(api.sync(), throwsA(isA<ApiException>().having((e) => e.isNetwork, 'isNetwork', isTrue)));
    expect(expired, 0);
  });
}
