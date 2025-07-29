class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final String? subCategory; // Kenyan-specific subcategories
  final bool isRecurring;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description = '',
    this.subCategory,
    this.isRecurring = false,
  });

  // Kenyan-specific categories
  static const List<String> kenyanCategories = [
    'Transport',
    'Utilities',
    'M-PESA',
    'Food',
    'Airtime',
    'Chama',
    'Entertainment',
    'Healthcare',
    'Education',
    'Savings',
    'Other',
  ];

  // Kenyan subcategories
  static const Map<String, List<String>> kenyanSubCategories = {
    'Transport': ['Matatu', 'Boda Boda', 'Uber/Bolt', 'Fuel', 'Parking'],
    'Utilities': ['KPLC', 'Nairobi Water', 'Internet', 'Garbage'],
    'M-PESA': ['Send Money', 'Paybill', 'Buy Goods', 'Withdraw', 'Airtime'],
    'Food': ['Groceries', 'Eating Out', 'Market', 'Supermarket'],
    'Chama': ['Contributions', 'Loans', 'Fines', 'Events'],
  };

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'subCategory': subCategory,
      'isRecurring': isRecurring,
      'currency': 'KES',
    };
  }

  // Create Expense from Firestore map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      category: map['category'],
      amount: map['amount'].toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      subCategory: map['subCategory'],
      isRecurring: map['isRecurring'] ?? false,
    );
  }
}
