import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/utils/currency_formatter.dart';
import 'package:pesa_planner/data/models/expense_model.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/expense_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ExpenseDashboard extends StatefulWidget {
  const ExpenseDashboard({super.key});

  @override
  State<ExpenseDashboard> createState() => _ExpenseDashboardState();
}

class _ExpenseDashboardState extends State<ExpenseDashboard> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context).currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view dashboard')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Dashboard'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: FutureBuilder<Map<String, double>>(
        future: Provider.of<ExpenseService>(
          context,
        ).getMonthlySummary(userId, _selectedMonth),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final summary = snapshot.data!;
          final total = summary.values.fold(0.0, (sum, amount) => sum + amount);
          final sortedSummary = summary.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return Column(
            children: [
              _buildMonthSelector(),
              _buildTotalCard(total),
              _buildPieChart(summary),
              _buildExpenseList(sortedSummary),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
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

  Widget _buildTotalCard(double total) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: AppColors.kenyaGreen.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Expenses:', style: TextStyle(fontSize: 18)),
            Text(
              formatKSH(total),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.kenyaGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> summary) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: summary.entries.map((entry) {
            return PieChartSectionData(
              color: _getCategoryColor(entry.key),
              value: entry.value,
              title:
                  '${(entry.value / summary.values.fold(0.0, (sum, amount) => sum + amount) * 100).toStringAsFixed(0)}%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildExpenseList(List<MapEntry<String, double>> expenses) {
    return Expanded(
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final entry = expenses[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(entry.key).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(entry.key),
                color: _getCategoryColor(entry.key),
              ),
            ),
            title: Text(entry.key),
            trailing: Text(
              formatKSH(entry.value),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Transport':
        return Colors.blue;
      case 'Utilities':
        return Colors.amber;
      case 'M-PESA':
        return Colors.green;
      case 'Food':
        return Colors.orange;
      case 'Chama':
        return Colors.purple;
      default:
        return AppColors.kenyaGreen;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Transport':
        return Icons.directions_bus;
      case 'Utilities':
        return Icons.bolt;
      case 'M-PESA':
        return Icons.phone_android;
      case 'Food':
        return Icons.fastfood;
      case 'Chama':
        return Icons.group;
      default:
        return Icons.money;
    }
  }
}
