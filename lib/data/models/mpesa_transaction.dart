import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/utils/currency_formatter.dart';
import 'package:pesa_planner/core/utils/date_utils.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/mpesa_service.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:intl/intl.dart';

class MpesaTransactionsScreen extends StatefulWidget {
  const MpesaTransactionsScreen({super.key});

  @override
  State<MpesaTransactionsScreen> createState() =>
      _MpesaTransactionsScreenState();
}

class _MpesaTransactionsScreenState extends State<MpesaTransactionsScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _transactions = [];
  String? _errorMessage;

  Future<void> _fetchTransactions() async {
    if (_phoneController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Provider.of<AuthService>(context, listen: false);
      final mpesaService = Provider.of<MpesaService>(context, listen: false);

      final transactions = await mpesaService.fetchTransactions(
        _phoneController.text,
      );

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isInitialized == null || !authService.isInitialized!) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authService.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view M-PESA transactions')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('M-PESA Transactions'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'M-PESA Phone Number',
                hintText: '07XX XXX XXX',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchTransactions,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchTransactions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kenyaGreen,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('FETCH TRANSACTIONS'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _transactions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No transactions found'),
                          Text(
                            'Enter your M-PESA number and fetch transactions',
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        final isReceived = transaction['type'] == 'Received';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isReceived
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isReceived
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isReceived ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              isReceived
                                  ? 'From: ${transaction['sender']}'
                                  : 'To: ${transaction['recipient']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction['reference']),
                                Text(formatKenyanDate(transaction['date'])),
                              ],
                            ),
                            trailing: Text(
                              '${isReceived ? '+' : '-'} ${formatKSH(transaction['amount'])}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isReceived ? Colors.green : Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on MpesaService {
  Future fetchTransactions(String text) {
    throw UnimplementedError('fetchTransactions method is not implemented');
  }
}
