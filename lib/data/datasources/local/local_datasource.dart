// Placeholder for local data operations
abstract class LocalDataSource {
  Future<void> saveExpense(Map<String, dynamic> expense);
  Future<List<Map<String, dynamic>>> getExpenses();
}
