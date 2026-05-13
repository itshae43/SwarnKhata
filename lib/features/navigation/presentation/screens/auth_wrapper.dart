import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_khata/features/auth/providers/auth_providers.dart';
import 'package:swarn_khata/features/auth/presentation/screens/login_screen.dart';
import 'package:swarn_khata/features/navigation/presentation/screens/main_screen.dart';

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
          return const MainScreen();
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
