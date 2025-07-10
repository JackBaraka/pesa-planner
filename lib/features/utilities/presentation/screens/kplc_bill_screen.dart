import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/utils/currency_formatter.dart';

class KPLCBillScreen extends StatefulWidget {
  const KPLCBillScreen({super.key});

  @override
  State<KPLCBillScreen> createState() => _KPLCBillScreenState();
}

class _KPLCBillScreenState extends State<KPLCBillScreen> {
  double _currentBill = 0.0;
  final List<double> _previousBills = [2450.0, 2100.0, 1890.0, 1750.0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KPLC Bill Tracker'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.kenyaGreen.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Current Bill'),
                    const SizedBox(height: 10),
                    Text(
                      formatKSH(_currentBill),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kenyaGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      value: _currentBill,
                      min: 0,
                      max: 5000,
                      divisions: 50,
                      label: formatKSH(_currentBill),
                      onChanged: (value) {
                        setState(() => _currentBill = value);
                      },
                      activeColor: AppColors.kenyaGreen,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Previous Bills',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _previousBills.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(
                      Icons.receipt,
                      color: AppColors.kenyaGreen,
                    ),
                    title: Text('Bill ${_previousBills.length - index}'),
                    trailing: Text(
                      formatKSH(_previousBills[index]),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _previousBills.insert(0, _currentBill);
            _currentBill = 0.0;
          });
        },
        backgroundColor: AppColors.kenyaGreen,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
