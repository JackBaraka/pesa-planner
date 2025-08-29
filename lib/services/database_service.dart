import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesa_planner/data/models/budget_model.dart';
import 'package:pesa_planner/data/models/expense_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Budget operations with null safety
  Future<String?> addBudget(String userId, Budget budget) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budget.id)
          .set(budget.toMap());
      return null; // Success
    } catch (e) {
      return 'Error adding budget: $e';
    }
  }

  Stream<List<Budget>> getBudgets(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .orderBy('startDate', descending: true)
          .snapshots()
          .handleError((error) {
            print('Error fetching budgets: $error');
            return Stream.value([]);
          })
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              try {
                final data = doc.data();
                if (data != null) {
                  return Budget.fromMap(data);
                }
                return Budget.createNew(
                  name: 'Invalid Budget',
                  amount: 0.0,
                  category: 'Other',
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 30)),
                );
              } catch (e) {
                print('Error parsing budget: $e');
                return Budget.createNew(
                  name: 'Corrupted Budget',
                  amount: 0.0,
                  category: 'Other',
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 30)),
                );
              }
            }).toList();
          });
    } catch (e) {
      print('Error in getBudgets stream: $e');
      return Stream.value([]);
    }
  }

  Future<String?> updateBudgetSpent(
    String userId,
    String budgetId,
    double newSpent,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .update({
            'spent': newSpent,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      return null; // Success
    } catch (e) {
      return 'Error updating budget: $e';
    }
  }

  Future<String?> deleteBudget(String userId, String budgetId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .delete();
      return null; // Success
    } catch (e) {
      return 'Error deleting budget: $e';
    }
  }

  // Expense operations with null safety
  Future<String?> addExpense(String userId, Expense expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expense.id)
          .set(expense.toMap());
      return null; // Success
    } catch (e) {
      return 'Error adding expense: $e';
    }
  }

  Stream<List<Expense>> getExpenses(String userId, {String? category}) {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .orderBy('date', descending: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      return query
          .snapshots()
          .handleError((error) {
            print('Error fetching expenses: $error');
            return Stream.value([]);
          })
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              try {
                final data = doc.data();
                if (data != null) {
                  return Expense.fromMap(data);
                }
                return Expense(
                  id: 'invalid',
                  category: 'Other',
                  amount: 0.0,
                  date: DateTime.now(),
                );
              } catch (e) {
                print('Error parsing expense: $e');
                return Expense(
                  id: 'corrupted',
                  category: 'Other',
                  amount: 0.0,
                  date: DateTime.now(),
                );
              }
            }).toList();
          });
    } catch (e) {
      print('Error in getExpenses stream: $e');
      return Stream.value([]);
    }
  }

  Future<String?> deleteExpense(String userId, String expenseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expenseId)
          .delete();
      return null; // Success
    } catch (e) {
      return 'Error deleting expense: $e';
    }
  }

  // Get expenses for a specific budget category
  Stream<List<Expense>> getExpensesForBudget(
    String userId,
    String budgetCategory,
  ) {
    return getExpenses(userId, category: budgetCategory);
  }

  // Update budget spent amount when expense is added
  Future<String?> updateBudgetOnExpense(String userId, Expense expense) async {
    try {
      // Get all budgets for the expense category
      final budgetsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .where('category', isEqualTo: expense.category)
          .where('startDate', isLessThanOrEqualTo: expense.date)
          .where('endDate', isGreaterThanOrEqualTo: expense.date)
          .get();

      if (budgetsSnapshot.docs.isNotEmpty) {
        for (var doc in budgetsSnapshot.docs) {
          final budgetData = doc.data();
          if (budgetData != null) {
            final currentSpent = (budgetData['spent'] ?? 0.0).toDouble();
            final newSpent = currentSpent + expense.amount;

            await doc.reference.update({
              'spent': newSpent,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
      return null; // Success
    } catch (e) {
      return 'Error updating budget with expense: $e';
    }
  }

  // Get monthly summary
  Future<Map<String, double>> getMonthlySummary(
    String userId,
    DateTime month,
  ) async {
    try {
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
        final data = doc.data();
        if (data != null) {
          try {
            final expense = Expense.fromMap(data);
            summary[expense.category] =
                (summary[expense.category] ?? 0.0) + expense.amount;
          } catch (e) {
            print('Error processing expense for summary: $e');
          }
        }
      }
      return summary;
    } catch (e) {
      print('Error getting monthly summary: $e');
      return {};
    }
  }

  // Check if user document exists, create if not
  Future<void> initializeUserData(String userId, String email) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(userId).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'currency': 'KES',
          'country': 'Kenya',
        });
      }
    } catch (e) {
      print('Error initializing user data: $e');
    }
  }
}
