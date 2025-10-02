import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pesa_planner/core/utils/currency_formatter.dart';
import 'package:pesa_planner/data/models/budget_model.dart';
import 'package:pesa_planner/data/models/expense_model.dart';
import 'package:pesa_planner/data/models/mpesa_transaction_model.dart';
import 'package:pesa_planner/data/models/kplc_bill_model.dart';
import 'package:intl/intl.dart';

class PDFService {
  // Generate comprehensive financial report
  Future<pw.Document> generateFinancialReport({
    required String userName,
    required DateTime startDate,
    required DateTime endDate,
    required List<Budget> budgets,
    required List<Expense> expenses,
    required List<MpesaTransaction> mpesaTransactions,
    required List<KPLCBill> kplcBills,
    required Map<String, double> expenseSummary,
    required Map<String, double> mpesaSummary,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: _kenyanTheme(),
        build: (context) => [
          _buildHeader(userName, startDate, endDate),
          _buildExecutiveSummary(expenseSummary, mpesaSummary, budgets),
          _buildExpenseAnalysis(expenses, expenseSummary),
          _buildBudgetPerformance(budgets),
          _buildMpesaAnalysis(mpesaTransactions, mpesaSummary),
          _buildUtilityAnalysis(kplcBills),
          _buildRecommendations(expenseSummary, budgets),
        ],
      ),
    );

    return pdf;
  }

  // Kenyan-themed PDF styling
  pw.ThemeData _kenyanTheme() {
    return pw.ThemeData.withFont(
      base: pw.Font.ttf(await rootBundle.load("fonts/Roboto-Regular.ttf")),
      bold: pw.Font.ttf(await rootBundle.load("fonts/Roboto-Bold.ttf")),
    ).copyWith(
      defaultTextStyle: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.black,
      ),
      header1: pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromInt(0xFF006600), // Kenya green
      ),
      header2: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromInt(0xFF006600),
      ),
      header3: pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black,
      ),
    );
  }

  // Report header with Kenyan elements
  pw.Widget _buildHeader(String userName, DateTime startDate, DateTime endDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PESA PLANNER FINANCIAL REPORT',
                  style: pw.Theme.of(context).header1,
                ),
                pw.Text('Generated for: $userName'),
                pw.Text('Period: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}'),
              ],
            ),
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF006600),
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Text(
                  'KES',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColor.fromInt(0xFFF0A800)), // Kenya gold
        pw.SizedBox(height: 10),
      ],
    );
  }

  // Executive summary section
  pw.Widget _buildExecutiveSummary(
    Map<String, double> expenseSummary,
    Map<String, double> mpesaSummary,
    List<Budget> budgets,
  ) {
    final totalExpenses = expenseSummary.values.fold(0.0, (sum, amount) => sum + amount);
    final totalMpesa = mpesaSummary.values.fold(0.0, (sum, amount) => sum + amount);
    final activeBudgets = budgets.where((b) => b.isActive).length;
    final completedBudgets = budgets.where((b) => b.status == BudgetStatus.completed).length;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('EXECUTIVE SUMMARY', style: pw.Theme.of(context).header2),
          pw.SizedBox(height: 10),
          pw.GridView(
            crossAxisCount: 2,
            childAspectRatio: 3,
            children: [
              _buildSummaryCard('Total Expenses', formatKSH(totalExpenses)),
              _buildSummaryCard('M-PESA Spending', formatKSH(totalMpesa)),
              _buildSummaryCard('Active Budgets', '$activeBudgets'),
              _buildSummaryCard('Completed Budgets', '$completedBudgets'),
            ],
          ),
        ],
      ),
    );
  }

  // Expense analysis section
  pw.Widget _buildExpenseAnalysis(List<Expense> expenses, Map<String, double> summary) {
    final sortedSummary = summary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('EXPENSE ANALYSIS', style: pw.Theme.of(context).header2),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF006600).withOpacity(0.1)),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Amount (KSh)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Percentage', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              for (final entry in sortedSummary.take(8))
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(entry.key),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(formatKSH(entry.value)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('${_calculatePercentage(entry.value, summary.values.fold(0.0, (sum, amount) => sum + amount)).toStringAsFixed(1)}%'),
                    ),
                  ],
                ),
            ],
          ),
          if (sortedSummary.length > 8)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Text('+ ${sortedSummary.length - 8} more categories...', style: pw.TextStyle(fontSize: 9)),
            ),
        ],
      ),
    );
  }

  // Budget performance section
  pw.Widget _buildBudgetPerformance(List<Budget> budgets) {
    final activeBudgets = budgets.where((b) => b.isActive).toList();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('BUDGET PERFORMANCE', style: pw.Theme.of(context).header2),
          pw.SizedBox(height: 10),
          if (activeBudgets.isEmpty)
            pw.Text('No active budgets for this period.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
          for (final budget in activeBudgets.take(5))
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(budget.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('${budget.progressPercentage}%', style: pw.TextStyle(
                        color: budget.isExceeded ? PdfColors.red : PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                      )),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Stack(
                    children: [
                      pw.Container(
                        width: double.infinity,
                        height: 8,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                      ),
                      pw.Container(
                        width: double.infinity * (budget.progress.clamp(0.0, 1.0)),
                        height: 8,
                        decoration: pw.BoxDecoration(
                          color: budget.isExceeded ? PdfColors.red : PdfColor.fromInt(0xFF006600),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Spent: ${budget.formattedSpent}', style: pw.TextStyle(fontSize: 9)),
                      pw.Text('Remaining: ${budget.formattedRemaining}', style: pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // M-PESA analysis section
  pw.Widget _buildMpesaAnalysis(List<MpesaTransaction> transactions, Map<String, double> summary) {
    final successfulTransactions = transactions.where((t) => t.isSuccessful).toList();
    final sortedSummary = summary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('M-PESA TRANSACTION ANALYSIS', style: pw.Theme.of(context).header2),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Transaction Types:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    for (final entry in sortedSummary.take(4))
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(entry.key),
                            pw.Text(formatKSH(entry.value)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF006600).withOpacity(0.1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('${successfulTransactions.length}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Transactions', style: pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Utility bills analysis
  pw.Widget _buildUtilityAnalysis(List<KPLCBill> bills) {
    final paidBills = bills.where((b) => b.isPaid).toList();
    final overdueBills = bills.where((b) => b.isOverdue).toList();
    final totalPaid = paidBills.fold(0.0, (sum, bill) => sum + bill.amount);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('UTILITY BILLS SUMMARY', style: pw.Theme.of(context).header2),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildUtilityCard('Total Paid', formatKSH(totalPaid), PdfColor.fromInt(0xFF006600)),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _buildUtilityCard('Paid Bills', '${paidBills.length}', PdfColors.blue),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _buildUtilityCard('Overdue', '${overdueBills.length}', PdfColors.red),
              ),
            ],
          ),
          if (overdueBills.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text('Overdue Bills:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            for (final bill in overdueBills.take(3))
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text('• ${bill.accountNumber} - ${bill.formattedAmount} (Due: ${DateFormat('dd/MM/yyyy').format(bill.dueDate)})', style: pw.TextStyle(fontSize: 9, color: PdfColors.red)),
              ),
          ],
        ],
      ),
    );
  }

  // Financial recommendations
  pw.Widget _buildRecommendations(Map<String, double> expenseSummary, List<Budget> budgets) {
    final recommendations = <String>[];
    final totalExpenses = expenseSummary.values.fold(0.0, (sum, amount) => sum + amount);

    // Analyze spending patterns
    final transportSpending = expenseSummary['Transport'] ?? 0;
    final foodSpending = expenseSummary['Food'] ?? 0;
    final mpesaSpending = expenseSummary['M-PESA'] ?? 0;

    if (transportSpending > totalExpenses * 0.2) {
      recommendations.add('Consider using public transport more often to reduce transport costs');
    }

    if (foodSpending > totalExpenses * 0.3) {
      recommendations.add('Try meal planning and cooking at home to reduce food expenses');
    }

    if (mpesaSpending > totalExpenses * 0.15) {
      recommendations.add('Limit M-PESA transaction fees by consolidating transfers');
    }

    final exceededBudgets = budgets.where((b) => b.isExceeded).length;
    if (exceededBudgets > 0) {
      recommendations.add('Review and adjust $exceededBudgets exceeded budget(s)');
    }

    final upcomingBills = budgets.where((b) => b.status == BudgetStatus.upcoming).length;
    if (upcomingBills > 0) {
      recommendations.add('Prepare for $upcomingBills upcoming budget(s) starting soon');
    }

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('FINANCIAL RECOMMENDATIONS', style: pw.Theme.of(context).header2),
          pw.SizedBox(height: 10),
          if (recommendations.isEmpty)
            pw.Text('Great job! Your finances are well managed.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
          for (final recommendation in recommendations)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Expanded(child: pw.Text(recommendation)),
                ],
              ),
            ),
          pw.SizedBox(height: 15),
          pw.Center(
            child: pw.Text(
              'Generated by Pesa Planner - Your Kenyan Financial Companion',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey, fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets
  pw.Widget _buildSummaryCard(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildUtilityCard(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  double _calculatePercentage(double value, double total) {
    return total > 0 ? (value / total) * 100 : 0;
  }

  // Generate budget-specific report
  Future<pw.Document> generateBudgetReport(Budget budget, List<Expense> relatedExpenses) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: _kenyanTheme(),
        build: (context) => [
          pw.Text('BUDGET REPORT: ${budget.name}', style: pw.Theme.of(context).header1),
          pw.SizedBox(height: 10),
          _buildBudgetDetails(budget),
          pw.SizedBox(height: 15),
          _buildBudgetExpenses(relatedExpenses),
          _buildBudgetInsights(budget, relatedExpenses),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _buildBudgetDetails(Budget budget) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
      },
      children: [
        _buildTableRow('Budget Name', budget.name),
        _buildTableRow('Category', budget.category),
        _buildTableRow('Period', '${DateFormat('dd MMM yyyy').format(budget.startDate)} - ${DateFormat('dd MMM yyyy').format(budget.endDate)}'),
        _buildTableRow('Total Budget', budget.formattedAmount),
        _buildTableRow('Amount Spent', budget.formattedSpent),
        _buildTableRow('Amount Remaining', budget.formattedRemaining),
        _buildTableRow('Progress', '${budget.progressPercentage}%'),
        _buildTableRow('Status', budget.status.displayName),
        _buildTableRow('Daily Budget', 'KSh ${budget.dailyBudget.toStringAsFixed(2)}'),
        _buildTableRow('Days Remaining', '${budget.daysRemaining} days'),
      ],
    );
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  pw.Widget _buildBudgetExpenses(List<Expense> expenses) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('RELATED EXPENSES', style: pw.Theme.of(context).header2),
        pw.SizedBox(height: 10),
        if (expenses.isEmpty)
          pw.Text('No expenses recorded for this budget.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
        for (final expense in expenses.take(10))
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(expense.description.isNotEmpty ? expense.description : 'No description'),
                      pw.Text(DateFormat('dd MMM yyyy').format(expense.date), style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                    ],
                  ),
                ),
                pw.Text(formatKSH(expense.amount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
        if (expenses.length > 10)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text('+ ${expenses.length - 10} more expenses...', style: pw.TextStyle(fontSize: 9)),
          ),
      ],
    );
  }

  pw.Widget _buildBudgetInsights(Budget budget, List<Expense> expenses) {
    final totalExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final averageExpense = expenses.isNotEmpty ? totalExpenses / expenses.length : 0;
    final daysElapsed = budget.daysElapsed;
    final dailyAverage = daysElapsed > 0 ? totalExpenses / daysElapsed : 0;

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('BUDGET INSIGHTS', style: pw.Theme.of(context).header2),
          pw.SizedBox(height: 10),
          pw.GridView(
            crossAxisCount: 2,
            childAspectRatio: 2,
            children: [
              _buildInsightCard('Total Expenses', formatKSH(totalExpenses)),
              _buildInsightCard('Number of Expenses', '${expenses.length}'),
              _buildInsightCard('Average per Expense', formatKSH(averageExpense)),
              _buildInsightCard('Daily Average', formatKSH(dailyAverage)),
            ],
          ),
          pw.SizedBox(height: 10),
          if (budget.isExceeded)
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.red.withOpacity(0.1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                '⚠️ Budget exceeded by ${formatKSH(budget.spent - budget.amount)}. Consider reviewing your spending habits.',
                style: pw.TextStyle(color: PdfColors.red),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildInsightCard(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}