import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_theme.dart';

class PhoneVerifyScreen extends StatelessWidget {
  const PhoneVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Kenyan Phone'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Enter your M-PESA registered number',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: '+254 7XX XXX XXX',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kenyaGreen,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('VERIFY PHONE'),
            ),
          ],
        ),
      ),
    );
  }
}
