import 'package:cloud_firestore/cloud_firestore.dart';

class KPLCBill {
  final String id;
  final String accountNumber;
  final String customerName;
  final double amount;
  final double amountPaid;
  final DateTime dueDate;
  final DateTime billDate;
  final DateTime? paidDate;
  final String status;
  final String? referenceNumber;
  final int unitsConsumed;
  final double previousReading;
  final double currentReading;
  final DateTime createdAt;
  final DateTime? updatedAt;

  KPLCBill({
    required this.id,
    required this.accountNumber,
    required this.customerName,
    required this.amount,
    this.amountPaid = 0.0,
    required this.dueDate,
    required this.billDate,
    this.paidDate,
    required this.status,
    this.referenceNumber,
    required this.unitsConsumed,
    required this.previousReading,
    required this.currentReading,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'customerName': customerName,
      'amount': amount,
      'amountPaid': amountPaid,
      'dueDate': Timestamp.fromDate(dueDate),
      'billDate': Timestamp.fromDate(billDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'status': status,
      'referenceNumber': referenceNumber,
      'unitsConsumed': unitsConsumed,
      'previousReading': previousReading,
      'currentReading': currentReading,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create KPLCBill from Firestore map
  factory KPLCBill.fromMap(Map<String, dynamic> map) {
    return KPLCBill(
      id: map['id'],
      accountNumber: map['accountNumber'],
      customerName: map['customerName'],
      amount: map['amount'].toDouble(),
      amountPaid: map['amountPaid']?.toDouble() ?? 0.0,
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      billDate: (map['billDate'] as Timestamp).toDate(),
      paidDate: map['paidDate'] != null
          ? (map['paidDate'] as Timestamp).toDate()
          : null,
      status: map['status'],
      referenceNumber: map['referenceNumber'],
      unitsConsumed: map['unitsConsumed'],
      previousReading: map['previousReading'].toDouble(),
      currentReading: map['currentReading'].toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Copy with method for updates
  KPLCBill copyWith({
    String? id,
    String? accountNumber,
    String? customerName,
    double? amount,
    double? amountPaid,
    DateTime? dueDate,
    DateTime? billDate,
    DateTime? paidDate,
    String? status,
    String? referenceNumber,
    int? unitsConsumed,
    double? previousReading,
    double? currentReading,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KPLCBill(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      amountPaid: amountPaid ?? this.amountPaid,
      dueDate: dueDate ?? this.dueDate,
      billDate: billDate ?? this.billDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      unitsConsumed: unitsConsumed ?? this.unitsConsumed,
      previousReading: previousReading ?? this.previousReading,
      currentReading: currentReading ?? this.currentReading,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get remaining amount to pay
  double get remainingAmount => amount - amountPaid;

  // Check if bill is paid
  bool get isPaid => status == 'paid';

  // Check if bill is overdue
  bool get isOverdue => !isPaid && DateTime.now().isAfter(dueDate);

  // Get days until due date (negative if overdue)
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  // Get consumption rate (units per day)
  double get consumptionRate {
    final days = billDate.difference(previousBillDate).inDays;
    return days > 0 ? unitsConsumed / days : 0.0;
  }

  // Estimate next bill date (typically 1 month later)
  DateTime get nextBillDate => billDate.add(const Duration(days: 30));

  // Estimate next bill amount based on consumption
  double get estimatedNextBill => consumptionRate * 30 * _getRatePerUnit();

  // Helper method to get rate per unit (simplified)
  double _getRatePerUnit() {
    if (unitsConsumed <= 100) return 12.75; // Domestic rate
    if (unitsConsumed <= 500) return 20.57; // Commercial rate
    return 25.30; // High consumption rate
  }

  // Get previous bill date (estimated)
  DateTime get previousBillDate => billDate.subtract(const Duration(days: 30));

  // Format amount with Kenyan currency
  String get formattedAmount => 'KSh ${amount.toStringAsFixed(2)}';
  String get formattedPaid => 'KSh ${amountPaid.toStringAsFixed(2)}';
  String get formattedRemaining => 'KSh ${remainingAmount.toStringAsFixed(2)}';

  // Bill status options
  static const List<String> statusOptions = [
    'pending',
    'paid',
    'overdue',
    'cancelled',
  ];

  // Create a new bill
  factory KPLCBill.createNew({
    required String accountNumber,
    required String customerName,
    required double amount,
    required DateTime dueDate,
    required DateTime billDate,
    required int unitsConsumed,
    required double previousReading,
    required double currentReading,
  }) {
    return KPLCBill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      accountNumber: accountNumber,
      customerName: customerName,
      amount: amount,
      amountPaid: 0.0,
      dueDate: dueDate,
      billDate: billDate,
      status: 'pending',
      unitsConsumed: unitsConsumed,
      previousReading: previousReading,
      currentReading: currentReading,
      createdAt: DateTime.now(),
    );
  }

  // Validate bill data
  static List<String> validateBill({
    required String accountNumber,
    required String amount,
    required DateTime dueDate,
    required double previousReading,
    required double currentReading,
  }) {
    final errors = <String>[];

    if (accountNumber.isEmpty) {
      errors.add('Account number is required');
    }

    if (amount.isEmpty) {
      errors.add('Amount is required');
    } else {
      final parsedAmount = double.tryParse(amount);
      if (parsedAmount == null || parsedAmount <= 0) {
        errors.add('Amount must be a positive number');
      }
    }

    if (dueDate.isBefore(DateTime.now())) {
      errors.add('Due date cannot be in the past');
    }

    if (currentReading <= previousReading) {
      errors.add('Current reading must be greater than previous reading');
    }

    return errors;
  }
}
