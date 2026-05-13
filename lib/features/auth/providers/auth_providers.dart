import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_khata/core/models/user_model.dart';
import 'package:swarn_khata/core/services/auth_service.dart';

// ─── AUTH SERVICE PROVIDER ──────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ─── FIREBASE AUTH USER STREAM ──────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ─── CURRENT USER FIRESTORE DATA ────────────────────────────────────
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(authServiceProvider).userStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ─── AUTH STATE MODEL ────────────────────────────────────────────────
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// ─── OTP STATE ───────────────────────────────────────────────────────
class OtpState {
  final bool isLoading;
  final bool isCodeSent;
  final String? verificationId;
  final String? error;

  const OtpState({
    this.isLoading = false,
    this.isCodeSent = false,
    this.verificationId,
    this.error,
  });

  OtpState copyWith({
    bool? isLoading,
    bool? isCodeSent,
    String? verificationId,
    String? error,
    bool clearError = false,
  }) {
    return OtpState(
      isLoading: isLoading ?? this.isLoading,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      verificationId: verificationId ?? this.verificationId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─── AUTH NOTIFIER (Riverpod v3 compatible) ──────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthService get _authService => ref.read(authServiceProvider);

  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e.code));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String businessName,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        businessName: businessName,
        phone: phone,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e.code));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e.code));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState();
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const AuthState();
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

// ─── OTP NOTIFIER (Riverpod v3 compatible) ───────────────────────────
class OtpNotifier extends Notifier<OtpState> {
  @override
  OtpState build() => const OtpState();

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);

    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        // Auto-verification (Android only)
        try {
          await _authService.signInWithOTP(
            verificationId: state.verificationId ?? '',
            smsCode: '',
          );
          state = state.copyWith(isLoading: false, isCodeSent: true);
        } catch (_) {
          state = state.copyWith(isLoading: false, isCodeSent: true);
        }
      },
      verificationFailed: (e) {
        state = state.copyWith(
          isLoading: false,
          error: e.message ?? 'Verification failed.',
        );
      },
      codeSent: (verificationId, resendToken) {
        state = state.copyWith(
          isLoading: false,
          isCodeSent: true,
          verificationId: verificationId,
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        state = state.copyWith(verificationId: verificationId);
      },
    );
  }

  Future<bool> verifyOtp(String smsCode) async {
    if (state.verificationId == null) {
      state = state.copyWith(
          error: 'Verification ID missing. Please resend OTP.');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signInWithOTP(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Invalid OTP. Please try again.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const OtpState();
  }
}

// ─── PROVIDERS ──────────────────────────────────────────────────────
final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final otpNotifierProvider =
    NotifierProvider<OtpNotifier, OtpState>(OtpNotifier.new);
