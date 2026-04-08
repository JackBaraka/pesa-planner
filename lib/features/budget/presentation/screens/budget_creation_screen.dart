import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/data/models/budget_model.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/database_service.dart';
import 'package:provider/provider.dart';

class BudgetCreationScreen extends StatefulWidget {
  final Budget? existingBudget;

  const BudgetCreationScreen({super.key, this.existingBudget});

  @override
  State<BudgetCreationScreen> createState() => _BudgetCreationScreenState();
}

class _BudgetCreationScreenState extends State<BudgetCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = Budget.kenyanCategories[0];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _monthlyRollover = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingBudget != null) {
      _nameController.text = widget.existingBudget!.name;
      _amountController.text = widget.existingBudget!.amount.toString();
      _descriptionController.text = widget.existingBudget!.description ?? '';
      _selectedCategory = widget.existingBudget!.category;
      _startDate = widget.existingBudget!.startDate;
      _endDate = widget.existingBudget!.endDate;
      _monthlyRollover = widget.existingBudget!.monthlyRollover;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
          // Auto-adjust end date if it's before start
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Budget name is required';
    }
    if (value.trim().length < 2) {
      return 'Budget name must be at least 2 characters';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount must be a positive number';
    }
    if (amount > 10000000) {
      return 'Amount cannot exceed KSh 10,000,000';
    }
    return null;
  }

  Future<void> _saveBudget(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final budget = Budget(
      id: widget.existingBudget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      spent: widget.existingBudget?.spent ?? 0.0,
      isRecurring: _monthlyRollover,
      monthlyRollover: _monthlyRollover,
      createdAt: widget.existingBudget?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final userId = Provider.of<AuthService>(
      context,
      listen: false,
    ).currentUser?.uid;

    if (userId != null) {
      final db = Provider.of<DatabaseService>(context, listen: false);
      String? error;

      if (widget.existingBudget != null) {
        error = await db.updateBudget(userId, budget);
      } else {
        error = await db.addBudget(userId, budget);
      }

      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingBudget != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Budget' : 'Create Budget'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Budget Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Budget Name *',
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Monthly Groceries',
                ),
                validator: _validateName,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (KSh) *',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 5000',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateAmount,
              ),
              const SizedBox(height: 20),

              // Category
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

              // Description (optional)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  hintText: 'Add notes about this budget',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Date Pickers
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start Date'),
                      subtitle: Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today, color: AppColors.kenyaGreen),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End Date'),
                      subtitle: Text(
                        '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today, color: AppColors.kenyaGreen),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Monthly Rollover Switch
              Card(
                child: SwitchListTile(
                  title: const Text('Monthly Rollover'),
                  subtitle: const Text(
                    'Carry over unused budget to next month',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _monthlyRollover,
                  activeColor: AppColors.kenyaGreen,
                  onChanged: (value) {
                    setState(() => _monthlyRollover = value);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Budget Summary Preview
              Card(
                color: AppColors.kenyaGreen.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Budget Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Duration:'),
                          Text(
                            '${_endDate.difference(_startDate).inDays + 1} days',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (_amountController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Daily Budget:'),
                            Text(
                              'KSh ${_formatNumber(_calculateDailyBudget())}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: () => _saveBudget(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kenyaGreen,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  isEditing ? 'UPDATE BUDGET' : 'CREATE BUDGET',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateDailyBudget() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final days = _endDate.difference(_startDate).inDays + 1;
    return days > 0 ? amount / days : 0;
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
