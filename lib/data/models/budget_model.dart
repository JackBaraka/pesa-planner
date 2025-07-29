import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String name;
  final double amount;
  double spent; // Track how much has been spent
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final String currency;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    this.spent = 0.0,
    required this.category,
    required this.startDate,
    required this.endDate,
    this.currency = 'KES',
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'spent': spent,
      'category': category,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'currency': currency,
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
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      currency: map['currency'] ?? 'KES',
    );
  }

  // Get progress percentage
  double get progress => spent / amount;

  // Get days remaining
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

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
}
