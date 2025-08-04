import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pesa_planner/data/models/user_model.dart'; // Ensure this import exists
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AppUser? _currentUser;

  AuthService() {
    // Initialize auth state listener
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = AppUser(
          uid: user.uid,
          email: user.email,
          phone: user.phoneNumber,
          displayName: user.displayName ?? 'User',
        );
      } else {
        _currentUser = null;
      }
      notifyListeners(); // Notify about user changes
    });
  }

  // Email sign-up with error message return
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Sign-up failed. Please try again.";
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
      return e.message ?? "Sign-in failed. Please check your credentials.";
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
    try {
      // Format Kenyan phone number
      String formattedPhone = phone;
      if (!phone.startsWith('+254')) {
        if (phone.startsWith('0')) {
          formattedPhone = '+254${phone.substring(1)}';
        } else {
          formattedPhone = '+254$phone';
        }
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
          if (onVerificationCompleted != null) {
            onVerificationCompleted(credential);
          }
        },
        verificationFailed: (e) =>
            onError(e.message ?? "Phone verification failed"),
        codeSent: (verificationId, resendToken) => onCodeSent(verificationId),
        codeAutoRetrievalTimeout: (verificationId) {
          if (onCodeAutoRetrievalTimeout != null) {
            onCodeAutoRetrievalTimeout();
          }
        },
        timeout: const Duration(seconds: 120),
      );
    } catch (e) {
      onError("Failed to verify phone number");
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
      return e.message ?? "Invalid OTP code";
    } catch (e) {
      return "Failed to sign in with OTP";
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Get current user (synchronous access)
  AppUser? get currentUser => _currentUser;

  // User stream for real-time auth state
  Stream<AppUser?> get user {
    return _auth.authStateChanges().map((User? firebaseUser) {
      if (firebaseUser == null) return null;

      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        phone: firebaseUser.phoneNumber,
        displayName: firebaseUser.displayName ?? 'User',
      );
    });
  }

  bool? get isInitialized => null;
}
