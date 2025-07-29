import 'package:hive/hive.dart';
import 'package:pesa_planner/data/models/budget_model.dart';

class DatabaseService {
  Future<void> syncLocalData() async {
    Hive.box('expenses');
    // Sync logic here
  }

  Future<void> addBudget(String userId, Budget budget) async {}

  void getBudgets(String userId) {}

  void deleteBudget(String userId, String budgetId) {}
}
