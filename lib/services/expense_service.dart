import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesa_planner/data/models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add expense with Kenyan context
  Future<void> addExpense(String userId, Expense expense) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toMap());
  }

  // Get expenses for a Kenyan user
  Stream<List<Expense>> getExpenses(String userId, {String? category}) {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Expense.fromMap(doc.data());
      }).toList();
    });
  }

  // Get monthly summary for Kenyan user
  Future<Map<String, double>> getMonthlySummary(
    String userId,
    DateTime month,
  ) async {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    Map<String, double> summary = {};
    for (var doc in snapshot.docs) {
      final expense = Expense.fromMap(doc.data());
      summary[expense.category] =
          (summary[expense.category] ?? 0) + expense.amount;
    }

    return summary;
  }

  // Delete expense
  Future<void> deleteExpense(String userId, String expenseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }
}
