import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/utils/currency_formatter.dart';
import 'package:pesa_planner/data/models/expense_model.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:provider/provider.dart' show Provider;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesa Planner'),
        backgroundColor: AppColors.kenyaGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Provider.of<AuthService>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('expenses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/empty_wallet.png', height: 120),
                  const SizedBox(height: 20),
                  const Text('No expenses recorded yet!'),
                  const SizedBox(height: 10),
                  Text(
                    'Start tracking your Kenyan shillings',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          double total = 0;
          final expenses = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            total += (data['amount'] as num).toDouble();
            return Expense(
              id: doc.id,
              category: data['category'] ?? 'Misc',
              amount: (data['amount'] as num).toDouble(),
              date: (data['date'] as Timestamp).toDate(),
              description: data['description'] ?? '',
            );
          }).toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                // ignore: deprecated_member_use
                color: AppColors.kenyaGreen.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Spent:'),
                    Text(
                      formatKSH(total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.kenyaGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      leading: Icon(
                        _getIconForCategory(expense.category),
                        color: AppColors.kenyaGreen,
                      ),
                      title: Text(expense.category),
                      subtitle: Text(expense.description),
                      trailing: Text(
                        formatKSH(expense.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.kenyaRed,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        backgroundColor: AppColors.kenyaGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Transport':
        return Icons.directions_bus;
      case 'Utilities':
        return Icons.bolt;
      case 'M-PESA':
        return Icons.phone_android;
      case 'Food':
        return Icons.fastfood;
      default:
        return Icons.money;
    }
  }

  void _showAddExpenseDialog(BuildContext context) {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Kenyan Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              items: Expense.kenyanCategories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) => categoryController.text = value!,
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount (KSh)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addExpense(
                context,
                categoryController.text,
                double.parse(amountController.text),
                descriptionController.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kenyaGreen,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addExpense(
    BuildContext context,
    String category,
    double amount,
    String description,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .add({
          'category': category,
          'amount': amount,
          'description': description,
          'date': Timestamp.now(),
          'currency': 'KES',
        });
  }
}
