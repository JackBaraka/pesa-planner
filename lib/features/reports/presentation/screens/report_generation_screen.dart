// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/data/models/budget_model.dart' show Budget;
import 'package:pesa_planner/data/models/expense_model.dart';
import 'package:pesa_planner/data/models/kplc_bill_model.dart';
import 'package:pesa_planner/data/models/mpesa_transaction_model.dart';
import 'package:pesa_planner/services/pdf_service.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/database_service.dart';
import 'package:pesa_planner/services/mpesa_transaction_service.dart';
import 'package:pesa_planner/services/kplc_service.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReportGenerationScreen extends StatefulWidget {
  const ReportGenerationScreen({super.key});

  @override
  State<ReportGenerationScreen> createState() => _ReportGenerationScreenState();
}

class _ReportGenerationScreenState extends State<ReportGenerationScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedReportType = 'financial';
  bool _isGenerating = false;

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    final userId = Provider.of<AuthService>(context).currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to generate reports')),
      );
      setState(() => _isGenerating = false);
      return;
    }

    try {
      final pdfService = PDFService();
      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );
      final mpesaService = Provider.of<MpesaTransactionService>(
        context,
        listen: false,
      );
      final kplcService = Provider.of<KPLCService>(context, listen: false);

      // Fetch data for the selected period
      final budgets = await _getBudgetsInPeriod(userId, databaseService);
      final expenses = await _getExpensesInPeriod(userId, databaseService);
      final mpesaTransactions = await _getMpesaTransactionsInPeriod(
        userId,
        mpesaService,
      );
      final kplcBills = await _getKPLCBillsInPeriod(userId, kplcService);

      // Calculate summaries
      final expenseSummary = _calculateExpenseSummary(expenses);
      final mpesaSummary = _calculateMpesaSummary(mpesaTransactions);

      final pdf = await pdfService.generateFinancialReport(
        userName: 'User', // You can get this from user profile
        startDate: _startDate,
        endDate: _endDate,
        budgets: budgets,
        expenses: expenses,
        mpesaTransactions: mpesaTransactions,
        kplcBills: kplcBills,
        expenseSummary: expenseSummary,
        mpesaSummary: mpesaSummary,
      );

      // Share or print the PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'pesa-planner-report.pdf',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report generated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating report: $e')));
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<List<Budget>> _getBudgetsInPeriod(
    String userId,
    DatabaseService service,
  ) async {
    // This is a simplified implementation
    // You might need to modify your DatabaseService to support date filtering
    final budgets = await service.getBudgets(userId).first;
    return budgets.where((budget) {
      return budget.startDate.isBefore(_endDate) &&
          budget.endDate.isAfter(_startDate);
    }).toList();
  }

  Future<List<Expense>> _getExpensesInPeriod(
    String userId,
    DatabaseService service,
  ) async {
    final expenses = await service.getExpenses(userId).first;
    return expenses.where((expense) {
      return expense.date.isAfter(_startDate) &&
          expense.date.isBefore(_endDate);
    }).toList();
  }

  Future<List<MpesaTransaction>> _getMpesaTransactionsInPeriod(
    String userId,
    MpesaTransactionService service,
  ) async {
    final transactions = await service.getMpesaTransactions(userId).first;
    return transactions.where((transaction) {
      return transaction.transactionDate.isAfter(_startDate) &&
          transaction.transactionDate.isBefore(_endDate);
    }).toList();
  }

  Future<List<KPLCBill>> _getKPLCBillsInPeriod(
    String userId,
    KPLCService service,
  ) async {
    final bills = await service.getKPLCBills(userId).first;
    return bills.where((bill) {
      return bill.billDate.isAfter(_startDate) &&
          bill.billDate.isBefore(_endDate);
    }).toList();
  }

  Map<String, double> _calculateExpenseSummary(List<Expense> expenses) {
    final summary = <String, double>{};
    for (final expense in expenses) {
      summary[expense.category] =
          (summary[expense.category] ?? 0) + expense.amount;
    }
    return summary;
  }

  Map<String, double> _calculateMpesaSummary(
    List<MpesaTransaction> transactions,
  ) {
    final summary = <String, double>{};
    for (final transaction in transactions.where((t) => t.isSuccessful)) {
      summary[transaction.transactionType] =
          (summary[transaction.transactionType] ?? 0) + transaction.amount;
    }
    return summary;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Report Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildReportTypeChip('Financial Summary', 'financial'),
                        _buildReportTypeChip('Budget Report', 'budget'),
                        _buildReportTypeChip('Expense Analysis', 'expense'),
                        _buildReportTypeChip('M-PESA Report', 'mpesa'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date Range Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Period',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Start Date'),
                            subtitle: Text(
                              DateFormat.yMMMd().format(_startDate),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('End Date'),
                            subtitle: Text(DateFormat.yMMMd().format(_endDate)),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Date Presets
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Periods',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildQuickPeriodChip('Last 7 Days'),
                        _buildQuickPeriodChip('Last 30 Days'),
                        _buildQuickPeriodChip('Last 90 Days'),
                        _buildQuickPeriodChip('This Month'),
                        _buildQuickPeriodChip('Last Month'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Generate Button
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kenyaGreen,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isGenerating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('GENERATE PDF REPORT'),
            ),
            const SizedBox(height: 16),

            // Report Preview Info
            Card(
              color: AppColors.kenyaGreen.withOpacity(0.1),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Includes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Executive Summary'),
                    Text('• Expense Analysis by Category'),
                    Text('• Budget Performance'),
                    Text('• M-PESA Transaction Summary'),
                    Text('• Utility Bills Overview'),
                    Text('• Financial Recommendations'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedReportType == value,
      onSelected: (selected) {
        setState(() => _selectedReportType = value);
      },
      selectedColor: AppColors.kenyaGreen.withOpacity(0.3),
    );
  }

  Widget _buildQuickPeriodChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        final now = DateTime.now();
        setState(() {
          switch (label) {
            case 'Last 7 Days':
              _startDate = now.subtract(const Duration(days: 7));
              _endDate = now;
              break;
            case 'Last 30 Days':
              _startDate = now.subtract(const Duration(days: 30));
              _endDate = now;
              break;
            case 'Last 90 Days':
              _startDate = now.subtract(const Duration(days: 90));
              _endDate = now;
              break;
            case 'This Month':
              _startDate = DateTime(now.year, now.month, 1);
              _endDate = now;
              break;
            case 'Last Month':
              _startDate = DateTime(now.year, now.month - 1, 1);
              _endDate = DateTime(now.year, now.month, 0);
              break;
          }
        });
      },
      backgroundColor: AppColors.kenyaGreen.withOpacity(0.1),
    );
  }
}

class KPLCService {
  getKPLCBills(String userId) {}
}
