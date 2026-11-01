import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;

  // lazy: Chrome (web) par ye bina client ID ke crash na kare
  late final GoogleSignIn _google = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  /// Returns the user, or null if the person closed the Google picker.
  Future<User?> signInWithGoogle() async {
    try {
      // ---- Web (Chrome): Firebase popup, google_sign_in ki zaroorat nahi
      if (kIsWeb) {
        final result = await _auth.signInWithPopup(GoogleAuthProvider());
        return result.user;
      }

      // ---- Android / iOS
      final account = await _google.signIn();
      if (account == null) return null; // cancelled

      final tokens = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: tokens.accessToken,
        idToken: tokens.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('GOOGLE SIGN-IN ERROR: ${e.code} | ${e.message}');
      // user ne popup band kar diya -> error mat dikhao
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

  Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    return result.user;
  }

  Future<User?> signUpWithEmail(
      String name, String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await result.user?.updateDisplayName(name.trim());
    return result.user;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() async {
    if (!kIsWeb) await _google.signOut();
    await _auth.signOut();
  }

  /// Turns errors into readable messages.
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
    // asli error dikhao taaki pata chale kya masla hai
    return 'Google sign-in failed: $e';
  }
}