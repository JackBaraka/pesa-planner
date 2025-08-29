import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show NavigatorState;
import 'package:flutter/widgets.dart' show GlobalKey;
import 'package:pesa_planner/services/database_service.dart';
import 'package:provider/provider.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  AuthService() {
    _auth.authStateChanges().listen(_authStateChanged);
  }

  void _authStateChanged(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  User? get currentUser => _currentUser;

  get isInitialized => null;

  // Email sign-up with error message return
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Initialize user data in Firestore
        final database = Provider.of<DatabaseService>(
          navigatorKey.currentContext!,
          listen: false,
        );
        await database.initializeUserData(result.user!.uid, email);
      }

      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return "An unknown error occurred during sign-up.";
    }
  }

  // Email sign-in with error message return
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return "An unknown error occurred during sign-in.";
    }
  }

  // Kenyan phone authentication
  Future<void> verifyKenyanPhone({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential)? onVerificationCompleted,
    Function()? onCodeAutoRetrievalTimeout,
  }) async {
    final formattedPhone = phone.startsWith('+254')
        ? phone
        : '+254${phone.substring(1)}';

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (credential) async {
          if (onVerificationCompleted != null) {
            onVerificationCompleted(credential);
          } else {
            await _auth.signInWithCredential(credential);
          }
        },
        verificationFailed: (e) => onError(_getAuthErrorMessage(e)),
        codeSent: (verificationId, resendToken) => onCodeSent(verificationId),
        codeAutoRetrievalTimeout: (verificationId) {
          if (onCodeAutoRetrievalTimeout != null) {
            onCodeAutoRetrievalTimeout();
          }
        },
        timeout: const Duration(seconds: 120),
      );
    } catch (e) {
      onError("Phone verification failed: $e");
    }
  }

  // Sign in with OTP code
  Future<String?> signInWithOTP(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return "An unknown error occurred during OTP sign-in.";
    }
  }

  // Sign out
  Future<String?> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
      return null; // success
    } catch (e) {
      return "Error signing out: $e";
    }
  }

  // Password reset
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return "An unknown error occurred during password reset.";
    }
  }

  // Helper method to get user-friendly error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email address is already in use.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'An unknown authentication error occurred.';
    }
  }
}

// Global navigator key for accessing context outside widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
