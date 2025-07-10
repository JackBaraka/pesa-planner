class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final bool isRecurring;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description = '',
    this.isRecurring = false,
  });

  static const List<String> kenyanCategories = [
    'Transport',
    'Utilities',
    'M-PESA',
    'Food',
    'Airtime',
    'Chama',
    'Entertainment',
    'Healthcare',
  ];
}

extension ExpenseCategoryExtension on String {
  bool get isValidKenyanCategory {
    return Expense.kenyanCategories.contains(this);
  }
}
