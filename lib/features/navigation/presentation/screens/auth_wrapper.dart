import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_khata/features/auth/providers/auth_providers.dart';
import 'package:swarn_khata/features/auth/presentation/screens/login_screen.dart';
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
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFFFF8F0),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFD4B13B)),
          ),
        ),
      ),
      error: (_, __) => const LoginScreen(),
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

  @override
  void initState() {
    super.initState();
    _initializeSession();
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

    final user = ref.watch(authStateProvider).value;
    if (user != null) {
      ref.listen<AsyncValue<List<SessionModel>>>(activeSessionsProvider, (previous, next) async {
        if (next.hasValue) {
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
    }

    return widget.child;
  }
}
