import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email sign-up with error message return
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
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
      return e.message;
    } catch (e) {
      return "An unknown error occurred during sign-in.";
    }
  }

  // Kenyan phone authentication with callbacks for OTP flow
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

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (credential) async {
        if (onVerificationCompleted != null) {
          onVerificationCompleted(credential);
        } else {
          await _auth.signInWithCredential(credential);
        }
      },
      verificationFailed: (e) =>
          onError(e.message ?? "Phone verification failed."),
      codeSent: (verificationId, resendToken) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (verificationId) {
        if (onCodeAutoRetrievalTimeout != null) {
          onCodeAutoRetrievalTimeout();
        }
      },
      timeout: const Duration(seconds: 120),
    );
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
      return e.message;
    } catch (e) {
      return "An unknown error occurred during OTP sign-in.";
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Optionally rethrow or handle error
    }
  }
  // Add this to notify listeners when auth state changes
  void _authStateChanged(User? user) {
    notifyListeners();
  }
  
  // Initialize listener in constructor
  AuthService() {
    _auth.authStateChanges().listen(_authStateChanged);
  }
}
}
