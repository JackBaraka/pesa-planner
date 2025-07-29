import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/utils/currency_formatter.dart';
import 'package:pesa_planner/core/utils/date_utils.dart';
import 'package:pesa_planner/data/models/expense_model.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/expense_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String? _selectedCategory;
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context).currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view expenses')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Expenses'),
        backgroundColor: AppColors.kenyaGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(context),
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: Provider.of<ExpenseService>(
                context,
              ).getExpenses(userId, category: _selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 20),
                        const Text('No expenses recorded yet'),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/add-expense'),
                          child: const Text('Add your first expense'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return _buildExpenseTile(context, expense, userId);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-expense'),
        backgroundColor: AppColors.kenyaGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(
    BuildContext context,
    Expense expense,
    String userId,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _getCategoryIcon(expense.category),
        title: Text(expense.category),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatKenyanDate(expense.date)),
            if (expense.subCategory != null) Text(expense.subCategory!),
            if (expense.description.isNotEmpty) Text(expense.description),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatKSH(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.kenyaRed,
              ),
            ),
            if (expense.isRecurring)
              const Text('Recurring', style: TextStyle(color: Colors.green)),
          ],
        ),
        onLongPress: () => _showDeleteDialog(context, userId, expense.id),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Expenses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('All Categories'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...Expense.kenyanCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedCategory = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedCategory = null);
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String userId,
    String expenseId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ExpenseService>(
                context,
                listen: false,
              ).deleteExpense(userId, expenseId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Icon _getCategoryIcon(String category) {
    final color = AppColors.kenyaGreen;
    switch (category) {
      case 'Transport':
        return const Icon(Icons.directions_bus, color: Colors.blue);
      case 'Utilities':
        return const Icon(Icons.bolt, color: Colors.amber);
      case 'M-PESA':
        return const Icon(Icons.phone_android, color: Colors.green);
      case 'Food':
        return const Icon(Icons.fastfood, color: Colors.orange);
      case 'Chama':
        return const Icon(Icons.group, color: Colors.purple);
      default:
        return Icon(Icons.money, color: color);
    }
  }
}
