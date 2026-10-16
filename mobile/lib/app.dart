import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/session.dart';
import 'features/caregiver/roster_screen.dart';
import 'features/login/login_screen.dart';
import 'features/parent/parent_home_screen.dart';
import 'providers.dart';
import 'theme.dart';

/// Lets bottom sheets show snackbars after they close.
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

class DaycareApp extends StatelessWidget {
  const DaycareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daycare',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      scaffoldMessengerKey: rootMessengerKey,
      locale: const Locale('id'),
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const _RootGate(),
    );
  }
}

class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return switch (session) {
      SessionLoading() => const Scaffold(body: Center(child: CircularProgressIndicator())),
      SignedOut(:final message) => LoginScreen(message: message),
      SignedIn(:final user) => _SyncLifecycle(
        key: ValueKey(user.id),
        child: user.role == Role.caregiver ? const RosterScreen() : const ParentHomeScreen(),
      ),
    };
  }
}

/// Keeps local data fresh while signed in: syncs on start, every minute,
/// when the app returns to the foreground and when the network comes back.
class _SyncLifecycle extends ConsumerStatefulWidget {
  const _SyncLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<_SyncLifecycle> createState() => _SyncLifecycleState();
}

class _SyncLifecycleState extends ConsumerState<_SyncLifecycle> {
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  AppLifecycleListener? _lifecycle;

  void _sync() => ref.read(syncServiceProvider).syncNow();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _sync());
    _lifecycle = AppLifecycleListener(onResume: _sync);
    _connectivity = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) _sync();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectivity?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
