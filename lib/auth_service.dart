
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In (lazy initialization)
  late final GoogleSignIn _google = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  // --------------------------------------------------
  // GOOGLE SIGN-IN
  // --------------------------------------------------

  Future<User?> signInWithGoogle() async {
    try {
      // Web Login
      if (kIsWeb) {
        final result = await _auth.signInWithPopup(
          GoogleAuthProvider(),
        );

        return result.user;
      }

      // Android Login
      final account = await _google.signIn();

      if (account == null) {
        return null;
      }

      final tokens = await account.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: tokens.accessToken,
        idToken: tokens.idToken,
      );

      final result = await _auth.signInWithCredential(
        credential,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'GOOGLE SIGN-IN ERROR: ${e.code} | ${e.message}',
      );

      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return null;
      }

      rethrow;
    } catch (e) {
      debugPrint('GOOGLE SIGN-IN ERROR: $e');
      rethrow;
    }
  }

  // --------------------------------------------------
  // EMAIL / PASSWORD LOGIN
  // --------------------------------------------------

  Future<User?> signInWithEmail(
    String email,
    String password,
  ) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return result.user;
  }

  // --------------------------------------------------
  // EMAIL / PASSWORD SIGNUP
  // --------------------------------------------------

  Future<User?> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await result.user?.updateDisplayName(name.trim());

    return result.user;
  }

  // --------------------------------------------------
  // FORGOT PASSWORD
  // --------------------------------------------------

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _google.signOut();
    }

    await _auth.signOut();
  }

  // --------------------------------------------------
  // ERROR HANDLING
  // --------------------------------------------------

  static String message(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email or password is incorrect.';

        case 'email-already-in-use':
          return 'This email is already registered.';

        case 'invalid-email':
          return 'Enter a valid email address.';

        case 'weak-password':
          return 'Password is too weak.';

        case 'network-request-failed':
          return 'No internet connection.';

        case 'operation-not-allowed':
          return 'Google sign-in is not enabled in Firebase console.';

        case 'unauthorized-domain':
          return 'This domain is not authorized in Firebase (Authentication > Settings > Authorized domains).';

        case 'popup-blocked':
          return 'Popup was blocked by the browser. Allow popups and try again.';

        default:
          return '${e.code}: ${e.message ?? 'Something went wrong.'}';
      }
    }

    return 'Authentication failed: $e';
  }
}
