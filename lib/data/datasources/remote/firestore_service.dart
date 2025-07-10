import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addExpense(String userId, Map<String, dynamic> expense) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .add(expense);
  }
}
