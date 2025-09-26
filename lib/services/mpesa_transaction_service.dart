import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesa_planner/data/models/mpesa_transaction_model.dart';

class MpesaTransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add M-PESA transaction
  Future<String?> addMpesaTransaction(
    String userId,
    MpesaTransaction transaction,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('mpesa_transactions')
          .doc(transaction.id)
          .set(transaction.toMap());
      return null; // Success
    } catch (e) {
      return 'Error adding M-PESA transaction: $e';
    }
  }

  // Get all M-PESA transactions for a user
  Stream<List<MpesaTransaction>> getMpesaTransactions(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('mpesa_transactions')
          .orderBy('transactionDate', descending: true)
          .snapshots()
          .handleError((error) {
            print('Error fetching M-PESA transactions: $error');
            return Stream.value([]);
          })
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              try {
                final data = doc.data();
                if (data != null) {
                  return MpesaTransaction.fromMap(data);
                }
                return MpesaTransaction.createNew(
                  transactionType: 'Unknown',
                  amount: 0.0,
                  phoneNumber: 'N/A',
                  accountNumber: 'N/A',
                );
              } catch (e) {
                print('Error parsing M-PESA transaction: $e');
                return MpesaTransaction.createNew(
                  transactionType: 'Unknown',
                  amount: 0.0,
                  phoneNumber: 'N/A',
                  accountNumber: 'N/A',
                );
              }
            }).toList();
          });
    } catch (e) {
      print('Error in getMpesaTransactions stream: $e');
      return Stream.value([]);
    }
  }

  // Update transaction status
  Future<String?> updateTransactionStatus(
    String userId,
    String transactionId,
    String status,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('mpesa_transactions')
          .doc(transactionId)
          .update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      return null; // Success
    } catch (e) {
      return 'Error updating transaction status: $e';
    }
  }

  // Get transactions by type
  Stream<List<MpesaTransaction>> getTransactionsByType(
    String userId,
    String transactionType,
  ) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('mpesa_transactions')
          .where('transactionType', isEqualTo: transactionType)
          .orderBy('transactionDate', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              try {
                final data = doc.data();
                if (data != null) {
                  return MpesaTransaction.fromMap(data);
                }
                return MpesaTransaction.createNew(
                  transactionType: transactionType,
                  amount: 0.0,
                  phoneNumber: 'N/A',
                  accountNumber: 'N/A',
                );
              } catch (e) {
                print('Error parsing transaction: $e');
                return MpesaTransaction.createNew(
                  transactionType: transactionType,
                  amount: 0.0,
                  phoneNumber: 'N/A',
                  accountNumber: 'N/A',
                );
              }
            }).toList();
          });
    } catch (e) {
      print('Error in getTransactionsByType stream: $e');
      return Stream.value([]);
    }
  }

  // Get monthly M-PESA spending summary
  Future<Map<String, double>> getMonthlySpendingSummary(
    String userId,
    DateTime month,
  ) async {
    try {
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('mpesa_transactions')
          .where(
            'transactionDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where(
            'transactionDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          )
          .where('status', isEqualTo: 'successful')
          .get();

      Map<String, double> summary = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data != null) {
          try {
            final transaction = MpesaTransaction.fromMap(data);
            summary[transaction.transactionType] =
                (summary[transaction.transactionType] ?? 0.0) +
                transaction.amount;
          } catch (e) {
            print('Error processing transaction for summary: $e');
          }
        }
      }
      return summary;
    } catch (e) {
      print('Error getting monthly spending summary: $e');
      return {};
    }
  }
}
