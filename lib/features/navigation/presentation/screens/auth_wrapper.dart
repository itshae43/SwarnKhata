import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_khata/features/auth/providers/auth_providers.dart';
import 'package:swarn_khata/features/auth/presentation/screens/otp_screen.dart';
import 'package:swarn_khata/features/navigation/presentation/screens/main_screen.dart';
import 'package:swarn_khata/core/models/session_model.dart';

/// Listens to Firebase auth state and routes to either
/// MainScreen (logged in) or LoginScreen (logged out).
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const SessionWrapper(child: MainScreen());
        }
        return const OtpScreen();
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFFFF8F0),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFD4B13B)),
          ),
        ),
      ),
      error: (_, __) => const OtpScreen(),
    );
  }
}

class SessionWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const SessionWrapper({super.key, required this.child});

  @override
  ConsumerState<SessionWrapper> createState() => _SessionWrapperState();
}

class _SessionWrapperState extends ConsumerState<SessionWrapper> {
  bool _isChecking = true;
  Timer? _autoLogoutTimer;

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _startAutoLogoutTimer();
  }

  void _startAutoLogoutTimer() {
    _autoLogoutTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final user = ref.read(currentUserProvider).value;
      if (user != null && user.role == 'user') {
        final nowIST = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
        if (nowIST.hour >= 20) {
          // It is 8 PM IST or later. Force logout.
          await ref.read(authNotifierProvider.notifier).signOut();
        }
      }
    });
  }

  @override
  void dispose() {
    _autoLogoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    try {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        final success = await ref
            .read(sessionServiceProvider)
            .registerOrUpdateSession(user.uid)
            .timeout(const Duration(seconds: 4), onTimeout: () {
          return true; // Fallback to proceed if timeout occurs
        });
        if (!success) {
          await ref.read(authNotifierProvider.notifier).signOut();
        }
      }
    } catch (e) {
      // Catch network or Firestore permission issues and proceed
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<SessionModel>>>(activeSessionsProvider, (previous, next) async {
      final user = ref.read(authStateProvider).value;
      if (user != null && next.hasValue) {
        final sessions = next.value ?? [];
        final localId = await ref.read(sessionServiceProvider).getLocalSessionId();
        if (localId != null) {
          final exists = sessions.any((s) => s.id == localId);
          if (!exists) {
            await ref.read(sessionServiceProvider).clearLocalSessionId();
            await ref.read(authNotifierProvider.notifier).signOut();
          }
        }
      }
    });

    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8F0),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFD4B13B)),
          ),
        ),
      );
    }

    return widget.child;
  }
}
