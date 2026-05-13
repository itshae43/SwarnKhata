import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─── AUTH STATE STREAM ──────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ─── EMAIL / PASSWORD SIGN IN ───────────────────────────────────
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ─── EMAIL / PASSWORD SIGN UP ───────────────────────────────────
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String businessName,
    required String phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user!.updateDisplayName(fullName);

    // Save user to Firestore
    await _saveUserToFirestore(
      uid: credential.user!.uid,
      fullName: fullName,
      businessName: businessName,
      email: email.trim(),
      phone: phone,
      photoUrl: '',
      authProvider: 'email',
    );

    return credential;
  }

  // ─── GOOGLE SIGN IN ─────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Check if user doc exists; if not, create one
    final userDoc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (!userDoc.exists) {
      await _saveUserToFirestore(
        uid: userCredential.user!.uid,
        fullName: googleUser.displayName ?? '',
        businessName: '',
        email: googleUser.email,
        phone: userCredential.user!.phoneNumber ?? '',
        photoUrl: googleUser.photoUrl ?? '',
        authProvider: 'google',
      );
    }

    return userCredential;
  }

  // ─── PHONE OTP ──────────────────────────────────────────────────
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);

    // Check if user doc exists
    final userDoc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (!userDoc.exists) {
      await _saveUserToFirestore(
        uid: userCredential.user!.uid,
        fullName: '',
        businessName: '',
        email: '',
        phone: userCredential.user!.phoneNumber ?? '',
        photoUrl: '',
        authProvider: 'phone',
      );
    }

    return userCredential;
  }

  // ─── FORGOT PASSWORD ────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ─── SIGN OUT ───────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── GET USER DATA ──────────────────────────────────────────────
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Stream<UserModel?> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  // ─── UPDATE USER PROFILE ────────────────────────────────────────
  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    String? businessName,
    String? phone,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    if (fullName != null) updates['fullName'] = fullName;
    if (businessName != null) updates['businessName'] = businessName;
    if (phone != null) updates['phone'] = phone;

    await _firestore.collection('users').doc(uid).update(updates);
  }

  // ─── PRIVATE: SAVE USER TO FIRESTORE ────────────────────────────
  Future<void> _saveUserToFirestore({
    required String uid,
    required String fullName,
    required String businessName,
    required String email,
    required String phone,
    required String photoUrl,
    required String authProvider,
  }) async {
    final now = DateTime.now();
    final user = UserModel(
      uid: uid,
      fullName: fullName,
      businessName: businessName,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      authProvider: authProvider,
      createdAt: now,
      updatedAt: now,
    );
    await _firestore.collection('users').doc(uid).set(user.toMap());
  }
}
