import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email sign-up
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Kenyan Sign-up Error (${e.code}): ${e.message}");
      return null;
    }
  }

  // Email sign-in
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Kenyan Sign-in Error (${e.code}): ${e.message}");
      return null;
    }
  }

  // Kenyan phone authentication
  Future<void> verifyKenyanPhone(String phone) async {
    // Format: +254XXXXXXXXX
    final formattedPhone = phone.startsWith('+254')
        ? phone
        : '+254${phone.substring(1)}';

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        print("Kenyan Phone Verification Failed: ${e.message}");
      },
      codeSent: (verificationId, resendToken) {
        // Implement OTP screen navigation
      },
      codeAutoRetrievalTimeout: (verificationId) {},
      timeout: const Duration(seconds: 120),
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
