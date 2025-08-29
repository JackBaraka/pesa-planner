// ignore_for_file: strict_top_level_inference

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Budget {
  final String id;
  final String name;
  final double amount;
  double spent; // Track how much has been spent
  final String category;
  final String? subCategory; // Kenyan-specific subcategories
  final DateTime startDate;
  final DateTime endDate;
  final String currency;
  final String? description;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    this.spent = 0.0,
    required this.category,
    this.subCategory,
    required this.startDate,
    required this.endDate,
    this.currency = 'KES',
    this.description,
    this.isRecurring = false,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'spent': spent,
      'category': category,
      'subCategory': subCategory,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'currency': currency,
      'description': description,
      'isRecurring': isRecurring,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create Budget from Firestore map
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      name: map['name'],
      amount: map['amount'].toDouble(),
      spent: map['spent'].toDouble(),
      category: map['category'],
      subCategory: map['subCategory'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      currency: map['currency'] ?? 'KES',
      description: map['description'],
      isRecurring: map['isRecurring'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Copy with method for updates
  Budget copyWith({
    String? id,
    String? name,
    double? amount,
    double? spent,
    String? category,
    String? subCategory,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
    String? description,
    bool? isRecurring,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get progress percentage (0.0 to 1.0)
  double get progress => amount > 0 ? spent / amount : 0.0;

  // Get progress percentage as integer (0 to 100)
  int get progressPercentage => (progress * 100).round();

  // Get days remaining (negative if overdue)
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  // Get days elapsed
  int get daysElapsed => DateTime.now().difference(startDate).inDays;

  // Get total days in budget period
  int get totalDays => endDate.difference(startDate).inDays;

  // Get daily budget amount
  double get dailyBudget => totalDays > 0 ? amount / totalDays : amount;

  // Get remaining amount
  double get remainingAmount => amount - spent;

  // Get daily spending allowance remaining
  double get dailyRemaining =>
      daysRemaining > 0 ? remainingAmount / daysRemaining : 0;

  // Check if budget is active
  bool get isActive =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  // Check if budget is completed
  bool get isCompleted => DateTime.now().isAfter(endDate);

  // Check if budget is overdue (past end date but not spent)
  bool get isOverdue => isCompleted && spent < amount;

  // Check if budget is exceeded
  bool get isExceeded => spent > amount;

  // Get budget status
  BudgetStatus get status {
    if (isCompleted) {
      return spent >= amount ? BudgetStatus.completed : BudgetStatus.overdue;
    } else if (isExceeded) {
      return BudgetStatus.exceeded;
    } else if (isActive) {
      return BudgetStatus.active;
    } else {
      return BudgetStatus.upcoming;
    }
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case BudgetStatus.active:
        return progress > 0.8
            ? '#FFA500'
            : '#4CAF50'; // Orange if >80%, else green
      case BudgetStatus.completed:
        return '#4CAF50'; // Green
      case BudgetStatus.exceeded:
        return '#F44336'; // Red
      case BudgetStatus.overdue:
        return '#FF5722'; // Deep orange
      case BudgetStatus.upcoming:
        return '#2196F3'; // Blue
    }
  }

  // Format amount with Kenyan currency
  String get formattedAmount =>
      'KSh ${NumberFormat('#,##0.00').format(amount)}';
  String get formattedSpent => 'KSh ${NumberFormat('#,##0.00').format(spent)}';
  String get formattedRemaining =>
      'KSh ${NumberFormat('#,##0.00').format(remainingAmount)}';

  // Kenyan-specific budget categories
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

  // Kenyan-specific subcategories
  static const Map<String, List<String>> kenyanSubCategories = {
    'Transport': [
      'Matatu',
      'Boda Boda',
      'Uber/Bolt',
      'Fuel',
      'Parking',
      'Taxi',
    ],
    'Utilities': [
      'KPLC',
      'Nairobi Water',
      'Internet',
      'Garbage',
      'Rent',
      'Security',
    ],
    'M-PESA': [
      'Send Money',
      'Paybill',
      'Buy Goods',
      'Withdraw',
      'Airtime',
      'Lipa Na M-PESA',
    ],
    'Food': [
      'Groceries',
      'Eating Out',
      'Market',
      'Supermarket',
      'Food Delivery',
    ],
    'Chama': ['Contributions', 'Loans', 'Fines', 'Events', 'Savings'],
    'Entertainment': ['Movies', 'Concerts', 'Sports', 'Bars', 'Restaurants'],
    'Healthcare': ['Hospital', 'Clinic', 'Medication', 'Insurance', 'Checkup'],
    'Education': ['School Fees', 'Books', 'Uniform', 'Transport', 'Lunch'],
  };

  // Get subcategories for a category
  static List<String> getSubCategories(String category) {
    return kenyanSubCategories[category] ?? [];
  }

  // Create a new budget with current timestamp
  factory Budget.createNew({
    required String name,
    required double amount,
    required String category,
    String? subCategory,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
    bool isRecurring = false,
  }) {
    return Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      amount: amount,
      spent: 0.0,
      category: category,
      subCategory: subCategory,
      startDate: startDate,
      endDate: endDate,
      currency: 'KES',
      description: description,
      isRecurring: isRecurring,
      createdAt: DateTime.now(),
    );
  }

  // Validate budget data
  static List<String> validateBudget({
    required String name,
    required String amount,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Budget name is required');
    }

    if (amount.isEmpty) {
      errors.add('Amount is required');
    } else {
      final parsedAmount = double.tryParse(amount);
      if (parsedAmount == null || parsedAmount <= 0) {
        errors.add('Amount must be a positive number');
      }
    }

    if (endDate.isBefore(startDate)) {
      errors.add('End date cannot be before start date');
    }

    if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      errors.add('Start date cannot be in the past');
    }

    return errors;
  }

  // Calculate suggested budget based on Kenyan living costs
  static Map<String, double> getSuggestedBudgets() {
    return {
      'Transport': 5000.0,
      'Utilities': 3000.0,
      'Food': 15000.0,
      'M-PESA': 2000.0,
      'Airtime': 1000.0,
      'Entertainment': 5000.0,
      'Healthcare': 3000.0,
      'Education': 10000.0,
      'Savings': 10000.0,
      'Other': 5000.0,
    };
  }
}

// Budget status enum
enum BudgetStatus { active, completed, exceeded, overdue, upcoming }

// Extension for status display
extension BudgetStatusExtension on BudgetStatus {
  String get displayName {
    switch (this) {
      case BudgetStatus.active:
        return 'Active';
      case BudgetStatus.completed:
        return 'Completed';
      case BudgetStatus.exceeded:
        return 'Exceeded';
      case BudgetStatus.overdue:
        return 'Overdue';
      case BudgetStatus.upcoming:
        return 'Upcoming';
    }
  }

  String get description {
    switch (this) {
      case BudgetStatus.active:
        return 'Budget is currently active';
      case BudgetStatus.completed:
        return 'Budget period has ended successfully';
      case BudgetStatus.exceeded:
        return 'Budget has been exceeded';
      case BudgetStatus.overdue:
        return 'Budget period ended without completion';
      case BudgetStatus.upcoming:
        return 'Budget will start soon';
    }
  }
}

Future<Map<String, dynamic>> sendMoney({
  required String phone,
  required double amount,
  required String reference,
}) async {
  if (!await isAccessTokenValid()) {
    throw Exception('M-PESA authentication failed');
  }

  try {
    // Format phone number
    String formattedPhone = phone;
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '254${formattedPhone.substring(1)}';
    } else if (!formattedPhone.startsWith('254')) {
      formattedPhone = '254$formattedPhone';
    }

    // Simulate API call
    await Future.delayed(const Duration(seconds: 3));

    // Return mock response
    return {
      'success': true,
      'transactionId': 'MPE${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Transaction initiated successfully',
      'amount': amount,
      'recipient': formattedPhone,
    };
  } catch (e) {
    throw Exception('Failed to send money: $e');
  }
}

Future<bool> isAccessTokenValid() async {
  // TODO: Implement the actual logic to validate the access token
  return false; // Default return value to avoid null
}
