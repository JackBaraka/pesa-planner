import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/data/models/budget_model.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/database_service.dart';
import 'package:provider/provider.dart';

class BudgetCreationScreen extends StatefulWidget {
  const BudgetCreationScreen({super.key});

  @override
  State<BudgetCreationScreen> createState() => _BudgetCreationScreenState();
}

class _BudgetCreationScreenState extends State<BudgetCreationScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = Budget.kenyanCategories[0];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createBudget(BuildContext context) async {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final budget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      startDate: _startDate,
      endDate: _endDate,
      createdAt: DateTime.now(),
    );

    final userId = Provider.of<AuthService>(
      context,
      listen: false,
    ).currentUser?.uid;
    if (userId != null) {
      await Provider.of<DatabaseService>(
        context,
        listen: false,
      ).addBudget(userId, budget);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Budget'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Budget Name',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (KSh)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: Budget.kenyanCategories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(
                      '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, true),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(
                      '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, false),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _createBudget(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kenyaGreen,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('CREATE BUDGET'),
            ),
          ],
        ),
      ),
    );
  }
}
