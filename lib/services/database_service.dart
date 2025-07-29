import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesa_planner/data/models/budget_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Budget operations
  Future<void> addBudget(String userId, Budget budget) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(budget.id)
        .set(budget.toMap());
  }

  Stream<List<Budget>> getBudgets(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Budget.fromMap(doc.data());
          }).toList();
        });
  }

  Future<void> deleteBudget(String userId, String budgetId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(budgetId)
        .delete();
  }

  // Expense operations
  Future<void> addExpense(String userId, Map<String, dynamic> expense) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .add(expense);
  }
}
