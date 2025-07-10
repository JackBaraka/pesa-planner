import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesa_planner/core/constants/firebase_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Kenyan expense
  Future<void> addKenyanExpense(String userId, Map<String, dynamic> expense) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection(FirebaseConstants.expensesCollection)
        .add({
          ...expense,
          'currency': 'KES',
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  // Get Kenyan expenses
  Stream<QuerySnapshot> getKenyanExpenses(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection(FirebaseConstants.expensesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
