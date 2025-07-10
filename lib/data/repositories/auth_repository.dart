import 'package:firebase_auth/firebase_auth.dart';
import 'package:pesa_planner/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<AppUser> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser == null
          ? AppUser(uid: '', displayName: 'Guest')
          : AppUser(
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              phone: firebaseUser.phoneNumber,
              displayName: firebaseUser.displayName ?? 'User',
            );
    });
  }
}
