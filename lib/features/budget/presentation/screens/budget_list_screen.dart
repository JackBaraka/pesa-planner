import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/utils/currency_formatter.dart';
import 'package:pesa_planner/data/models/budget_model.dart';
import 'package:pesa_planner/features/budget/presentation/screens/budget_creation_screen.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/database_service.dart';
import 'package:provider/provider.dart';

class BudgetListScreen extends StatelessWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context).currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view budgets')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Budgets'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: StreamBuilder<List<Budget>>(
        stream: Provider.of<DatabaseService>(context).getBudgets(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final budgets = snapshot.data ?? [];

          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.money_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text('No budgets created yet'),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BudgetCreationScreen(),
                      ),
                    ),
                    child: const Text('Create your first budget'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final daysLeft = budget.daysRemaining;
              final progress = budget.progress;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(budget.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        color: progress > 0.8
                            ? Colors.red
                            : AppColors.kenyaGreen,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${formatKSH(budget.spent)} / ${formatKSH(budget.amount)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$daysLeft days left',
                            style: TextStyle(
                              color: daysLeft < 7 ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteBudget(context, userId, budget.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BudgetCreationScreen()),
        ),
        backgroundColor: AppColors.kenyaGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteBudget(BuildContext context, String userId, String budgetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<DatabaseService>(
                context,
                listen: false,
              ).deleteBudget(userId, budgetId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
