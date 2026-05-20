import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_khata/core/models/user_model.dart';
import 'package:swarn_khata/core/models/session_model.dart';
import 'package:swarn_khata/core/services/auth_service.dart';
import 'package:swarn_khata/core/services/session_service.dart';

// ─── AUTH SERVICE PROVIDER ──────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ─── SESSION SERVICE PROVIDER ───────────────────────────────────────
final sessionServiceProvider = Provider<SessionService>((ref) => SessionService());

// ─── FIREBASE AUTH USER STREAM ──────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ─── DEDICATED USER PROFILES COLLECTION STREAM ─────────────────────────
final userProfilesProvider = StreamProvider<List<UserModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('user_profiles')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) => user.role != 'admin')
          .toList());
});

// ─── PENDING LOGIN REQUESTS (ADMIN) ───────────────────────────────
final pendingLoginRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('login_requests')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
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

// ─── ACTIVE SESSIONS PROVIDER ───────────────────────────────────────
final activeSessionsProvider = StreamProvider<List<SessionModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.watch(sessionServiceProvider).getSessionsStream(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
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

  Future<void> updateLoginStatus(String uid, bool isLoggedIn) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isLoggedIn': isLoggedIn,
    });
  }

  Future<void> signOut() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final sessionId = await ref.read(sessionServiceProvider).getLocalSessionId();
        if (sessionId != null) {
          await ref
              .read(sessionServiceProvider)
              .deleteSession(user.uid, sessionId)
              .timeout(const Duration(seconds: 2));
        }
      }
    } catch (e) {
      // Ignore errors during session deletion
    }
    
    try {
      await ref.read(sessionServiceProvider).clearLocalSessionId();
    } catch (_) {}
    
    try {
      final user = _authService.currentUser;
      if (user != null) {
        await updateLoginStatus(user.uid, false);
      }
    } catch (_) {}

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

  Future<void> sendLoginRequest(UserModel user) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('login_requests').add({
        'uid': user.uid,
        'name': user.fullName,
        'phone': user.phone,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, approved, declined
      });
      state = state.copyWith(
        isLoading: false,
        verificationId: 'mock_other_verification_id', // Set this so verifyOtp succeeds!
        error: 'Login request sent to Admin. Waiting for approval...',
      ); // Using error state just to show message in UI for now
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to send request');
    }
  }

  Future<UserModel?> createNewUser(String name, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone == '9671900007' || cleanPhone == '919671900007') {
      state = state.copyWith(
        isLoading: false,
        error: 'Cannot create a user profile with the Admin\'s phone number.',
      );
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await _authService.signInMockOther(phone: phone, name: name);
      final user = await _authService.getUserData(credential.user!.uid);
      // Immediately log them out after creation so they go to pending list
      await _authService.signOut();
      state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create user');
      return null;
    }
  }

  Future<bool> verifyAdmin({required String pin}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // ── 1. Validate PIN ───────────────────────────────────────────────
    const adminPin = '112211';
    if (pin != adminPin) {
      state = state.copyWith(
        isLoading: false,
        error: 'Incorrect PIN. Please try again.',
      );
      return false;
    }

    try {
      // ── 2. Check single-admin rule ────────────────────────────────
      final firestore = FirebaseFirestore.instance;
      final adminsSnap = await firestore.collection('admins').limit(1).get();

      if (adminsSnap.docs.isNotEmpty) {
        // There is already an admin document. Verify it belongs to the
        // same Firebase account we are about to sign into.
        final existingAdminUid = adminsSnap.docs.first.id;

        // Try signing in; if it succeeds the UIDs must match.
        final credential = await _authService.signInMockAdmin();
        if (credential.user?.uid != existingAdminUid) {
          // Different admin already exists — block login.
          await _authService.signOut();
          state = state.copyWith(
            isLoading: false,
            error: 'Another admin already exists. Delete the existing admin first.',
          );
          return false;
        }
        state = state.copyWith(isLoading: false);
        return true;
      }

      // ── 3. No admin yet — create & sign in ────────────────────────
      await Future.delayed(const Duration(milliseconds: 800));
      await _authService.signInMockAdmin();
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Authentication failed.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> sendOtp(String phoneNumber, {required String role}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // Admin now uses PIN — OTP path is only for 'other' users.
    // Mock the OTP send flow to bypass Firebase phone auth billing.
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(
      isLoading: false,
      isCodeSent: true,
      verificationId: 'mock_other_verification_id',
    );
  }

  Future<bool> verifyOtp(String smsCode, {
    required String role,
    required String phone,
    String? name,
  }) async {
    final effectiveVerificationId = role == 'other' 
        ? (state.verificationId ?? 'mock_other_verification_id')
        : state.verificationId;

    if (effectiveVerificationId == null) {
      state = state.copyWith(
          error: 'Verification ID missing. Please resend OTP.');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);

    // Only 'other' users flow through verifyOtp. Admin uses verifyAdmin(pin).
    if (effectiveVerificationId == 'mock_other_verification_id') {
      try {
        await _authService.signInMockOther(
          phone: phone,
          name: name ?? 'Other User',
        );
        state = state.copyWith(isLoading: false);
        return true;
      } on FirebaseAuthException catch (e) {
        state = state.copyWith(
          isLoading: false,
          error: e.message ?? 'Authentication failed.',
        );
        return false;
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
        return false;
      }
    }


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
