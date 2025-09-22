import 'package:cloud_firestore/cloud_firestore.dart';

class MpesaTransaction {
  final String id;
  final String transactionType;
  final double amount;
  final String phoneNumber;
  final String accountNumber;
  final DateTime transactionDate;
  final String status;
  final String? reference;
  final String? description;
  final String? conversationId;
  final String? originatorConversationId;
  final DateTime createdAt;

  MpesaTransaction({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.phoneNumber,
    required this.accountNumber,
    required this.transactionDate,
    required this.status,
    this.reference,
    this.description,
    this.conversationId,
    this.originatorConversationId,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionType': transactionType,
      'amount': amount,
      'phoneNumber': phoneNumber,
      'accountNumber': accountNumber,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'status': status,
      'reference': reference,
      'description': description,
      'conversationId': conversationId,
      'originatorConversationId': originatorConversationId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create MpesaTransaction from Firestore map
  factory MpesaTransaction.fromMap(Map<String, dynamic> map) {
    return MpesaTransaction(
      id: map['id'],
      transactionType: map['transactionType'],
      amount: map['amount'].toDouble(),
      phoneNumber: map['phoneNumber'],
      accountNumber: map['accountNumber'],
      transactionDate: (map['transactionDate'] as Timestamp).toDate(),
      status: map['status'],
      reference: map['reference'],
      description: map['description'],
      conversationId: map['conversationId'],
      originatorConversationId: map['originatorConversationId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // M-PESA transaction types
  static const List<String> transactionTypes = [
    'Paybill',
    'Buy Goods',
    'Send Money',
    'Withdraw',
    'Airtime',
    'Lipa Na M-PESA',
  ];

  // Transaction status options
  static const List<String> statusOptions = [
    'pending',
    'successful',
    'failed',
    'cancelled',
  ];

  // Kenyan paybill numbers for common services
  static const Map<String, String> paybillNumbers = {
    'KPLC': '888888',
    'Nairobi Water': '888880',
    'DStv': '955500',
    'Zuku': '222222',
    'GOTv': '555555',
    'Startimes': '777777',
  };

  // Format amount with Kenyan currency
  String get formattedAmount => 'KSh ${amount.toStringAsFixed(2)}';

  // Check if transaction is successful
  bool get isSuccessful => status == 'successful';

  // Check if transaction is pending
  bool get isPending => status == 'pending';

  // Get transaction type icon
  String get transactionIcon {
    switch (transactionType) {
      case 'Paybill':
        return '💰';
      case 'Buy Goods':
        return '🛒';
      case 'Send Money':
        return '📤';
      case 'Withdraw':
        return '🏧';
      case 'Airtime':
        return '📱';
      case 'Lipa Na M-PESA':
        return '💳';
      default:
        return '💸';
    }
  }

  // Create a new M-PESA transaction
  factory MpesaTransaction.createNew({
    required String transactionType,
    required double amount,
    required String phoneNumber,
    required String accountNumber,
    String? description,
  }) {
    return MpesaTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      transactionType: transactionType,
      amount: amount,
      phoneNumber: phoneNumber,
      accountNumber: accountNumber,
      transactionDate: DateTime.now(),
      status: 'pending',
      description: description,
      createdAt: DateTime.now(),
    );
  }

  // Validate M-PESA transaction data
  static List<String> validateTransaction({
    required String phoneNumber,
    required String amount,
    required String accountNumber,
  }) {
    final errors = <String>[];

    // Validate phone number (Kenyan format)
    if (!RegExp(r'^(07|01)\d{8}$').hasMatch(phoneNumber)) {
      errors.add(
        'Please enter a valid Kenyan phone number (07xxxxxxxx or 01xxxxxxxx)',
      );
    }

    // Validate amount
    if (amount.isEmpty) {
      errors.add('Amount is required');
    } else {
      final parsedAmount = double.tryParse(amount);
      if (parsedAmount == null || parsedAmount <= 0) {
        errors.add('Amount must be a positive number');
      } else if (parsedAmount < 10) {
        errors.add('Minimum amount is KSh 10');
      } else if (parsedAmount > 150000) {
        errors.add('Maximum amount is KSh 150,000');
      }
    }

    // Validate account number
    if (accountNumber.isEmpty) {
      errors.add('Account number is required');
    }

    return errors;
  }
}
