class MpesaTransaction {
  final String transactionId;
  final double amount;
  final DateTime date;
  final String recipient;
  final String reference;

  MpesaTransaction({
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.recipient,
    required this.reference,
  });
}
