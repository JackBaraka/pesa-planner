class Budget {
  final String id;
  final String name;
  final double amount;
  final String category;
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.startDate,
    required this.endDate,
  });
}
