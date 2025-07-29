import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/data/models/expense_model.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/expense_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = Expense.kenyanCategories[0];
  String? _selectedSubCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      description: _descriptionController.text,
      subCategory: _selectedSubCategory,
      isRecurring: _isRecurring,
    );

    final userId = Provider.of<AuthService>(context).currentUser?.uid;
    if (userId != null) {
      await Provider.of<ExpenseService>(
        context,
        listen: false,
      ).addExpense(userId, expense);
      Navigator.pop(context);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final subCategories = Expense.kenyanSubCategories[_selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Kenyan Expense'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Category Selection
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: Expense.kenyanCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                      _selectedSubCategory = null;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),

              // Subcategory Selection (if available)
              if (subCategories.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedSubCategory,
                  hint: const Text('Select Subcategory'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...subCategories.map((subCat) {
                      return DropdownMenuItem(
                        value: subCat,
                        child: Text(subCat),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedSubCategory = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Subcategory',
                    prefixIcon: Icon(Icons.list),
                  ),
                ),
              if (subCategories.isNotEmpty) const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (KSh)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter amount';
                  if (double.tryParse(value) == null)
                    return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Date Selection
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Recurring Toggle
              SwitchListTile(
                title: const Text('Recurring Expense'),
                subtitle: const Text('e.g. Monthly bills'),
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
                activeColor: AppColors.kenyaGreen,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kenyaGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ADD EXPENSE', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
