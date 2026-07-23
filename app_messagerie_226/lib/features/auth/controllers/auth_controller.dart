import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Providers Firebase ---
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// --- État auth ---
enum AuthStep { idle, codeSent, loading, error }

class AuthState {
  final AuthStep step;
  final String? verificationId;
  final String? errorMessage;
  final User? user;

  const AuthState({
    this.step = AuthStep.idle,
    this.verificationId,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStep? step,
    String? verificationId,
    String? errorMessage,
    User? user,
  }) =>
      AuthState(
        step: step ?? this.step,
        verificationId: verificationId ?? this.verificationId,
        errorMessage: errorMessage ?? this.errorMessage,
        user: user ?? this.user,
      );
}

// --- Controller ---
class AuthController extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;

  AuthController(this._auth) : super(const AuthState());

  /// Envoie le code OTP au numéro +226XXXXXXXX
  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(step: AuthStep.loading);
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: null,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        state = state.copyWith(
          step: AuthStep.error,
          errorMessage: e.message ?? 'Erreur lors de l\'envoi du code',
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        state = state.copyWith(
          step: AuthStep.codeSent,
          verificationId: verificationId,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        state = state.copyWith(verificationId: verificationId);
      },
    );
  }

  /// Vérifie le code OTP saisi par l'utilisateur
  Future<bool> verifyOtp(String smsCode) async {
    if (state.verificationId == null) return false;
    state = state.copyWith(step: AuthStep.loading);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        step: AuthStep.error,
        errorMessage: e.message ?? 'Code incorrect',
      );
      return false;
    }
  }

  void reset() => state = const AuthState();
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(firebaseAuthProvider));
});

// --- Utilisateur courant ---
final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// --- Profil Firestore de l'utilisateur courant ---
final userProfileProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, uid) async {
    final doc = await ref.watch(firestoreProvider).collection('users').doc(uid).get();
    return doc.data();
  },
);
