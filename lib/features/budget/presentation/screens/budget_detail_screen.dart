import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/utils/currency_formatter.dart';
import 'package:pesa_planner/data/models/budget_model.dart';
import 'package:pesa_planner/features/budget/presentation/screens/budget_creation_screen.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/database_service.dart';
import 'package:provider/provider.dart';

class BudgetDetailScreen extends StatelessWidget {
  final String budgetId;

  const BudgetDetailScreen({super.key, required this.budgetId});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (!authService.isInitialized || authService.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    final userId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Details'),
        backgroundColor: AppColors.kenyaGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editBudget(context, userId),
          ),
        ],
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
          final budget = budgets.firstWhere(
            (b) => b.id == budgetId,
            orElse: () => Budget.createNew(
              name: 'Not Found',
              amount: 0,
              category: 'Other',
              startDate: DateTime.now(),
              endDate: DateTime.now().add(const Duration(days: 30)),
            ),
          );

          if (budget.name == 'Not Found') {
            return const Center(child: Text('Budget not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                budget.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatusChip(budget),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(budget.category),
                          backgroundColor: AppColors.kenyaGreen.withOpacity(0.2),
                        ),
                        if (budget.monthlyRollover) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 16,
                                color: AppColors.kenyaGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Monthly Rollover enabled',
                                style: TextStyle(
                                  color: AppColors.kenyaGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Budget vs Actual Spending Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Budget vs Actual Spending',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Spending Bar
                        _buildSpendingBar(context, budget),
                        const SizedBox(height: 20),

                        // Amount Details
                        _buildAmountRow(
                          'Budgeted Amount',
                          budget.formattedAmount,
                          Colors.grey[700]!,
                        ),
                        const Divider(height: 16),
                        _buildAmountRow(
                          'Spent',
                          budget.formattedSpent,
                          _getProgressColor(budget.progressColor),
                        ),
                        const Divider(height: 16),
                        _buildAmountRow(
                          'Remaining',
                          budget.formattedRemaining,
                          budget.remainingAmount >= 0
                              ? AppColors.kenyaGreen
                              : Colors.red,
                        ),

                        if (budget.isExceeded) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'You have exceeded your budget by KSh ${formatKSH(budget.spent - budget.amount)}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (budget.isWarning) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.kenyaGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: AppColors.kenyaGold),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Warning: You have used ${budget.progressPercentage}% of your budget!',
                                    style: TextStyle(
                                      color: AppColors.kenyaGold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time Progress Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTimeProgressBar(budget),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Started',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '${budget.startDate.day}/${budget.startDate.month}/${budget.startDate.year}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Ends',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '${budget.endDate.day}/${budget.endDate.month}/${budget.endDate.year}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            budget.daysRemaining >= 0
                                ? '${budget.daysRemaining} days remaining'
                                : '${budget.daysRemaining.abs()} days overdue',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: budget.daysRemaining < 0 ? Colors.red : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Daily Budget Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Budget',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDailyStat(
                              'Daily Budget',
                              'KSh ${formatKSH(budget.dailyBudget)}',
                            ),
                            _buildDailyStat(
                              'Remaining Today',
                              'KSh ${formatKSH(budget.dailyRemaining)}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                if (budget.description != null && budget.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(budget.description!),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(Budget budget) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String label;

    switch (budget.status) {
      case BudgetStatus.active:
        backgroundColor = budget.isWarning ? AppColors.kenyaGold : AppColors.kenyaGreen;
        textColor = Colors.white;
        label = budget.isWarning ? 'Warning' : 'Active';
        break;
      case BudgetStatus.completed:
        backgroundColor = Colors.blue;
        label = 'Completed';
        break;
      case BudgetStatus.exceeded:
        backgroundColor = Colors.red;
        label = 'Exceeded';
        break;
      case BudgetStatus.overdue:
        backgroundColor = Colors.orange;
        label = 'Overdue';
        break;
      case BudgetStatus.upcoming:
        backgroundColor = Colors.grey;
        label = 'Upcoming';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildSpendingBar(BuildContext context, Budget budget) {
    final progress = budget.progress.clamp(0.0, 1.0);
    final progressColor = _getProgressColor(budget.progressColor);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${budget.progressPercentage}% used',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
            Text(
              budget.isExceeded
                  ? '${((budget.progress - 1).abs() * 100).toStringAsFixed(1)}% over'
                  : '${((1 - budget.progress) * 100).toStringAsFixed(1)}% left',
              style: TextStyle(
                color: budget.isExceeded ? Colors.red : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Background
            Container(
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Progress
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // 90% warning line
            Positioned(
              left: MediaQuery.of(context).size.width * 0.72, // ~90% position
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: Colors.red.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'KSh 0',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              budget.formattedAmount,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeProgressBar(Budget budget) {
    final totalDays = budget.totalDays;
    final elapsedDays = budget.daysElapsed;
    final progress = totalDays > 0 ? (elapsedDays / totalDays).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${budget.daysElapsed} days elapsed',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${budget.totalDays} days total',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            color: AppColors.kenyaGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(String hexColor) {
    switch (hexColor) {
      case '#F44336':
        return Colors.red;
      case '#F0A800':
        return AppColors.kenyaGold;
      case '#FFA500':
        return Colors.orange;
      case '#4CAF50':
        return AppColors.kenyaGreen;
      default:
        return AppColors.kenyaGreen;
    }
  }

  void _editBudget(BuildContext context, String userId) async {
    final budgets = await Provider.of<DatabaseService>(context, listen: false)
        .getBudgets(userId)
        .first;
    final budget = budgets.firstWhere((b) => b.id == budgetId);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BudgetCreationScreen(existingBudget: budget),
        ),
      );
    }
  }
}
