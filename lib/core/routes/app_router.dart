// ignore_for_file: avoid_types_as_parameter_names

import 'package:flutter/material.dart';
import 'package:pesa_planner/features/auth/presentation/screens/login_screen.dart';
import 'package:pesa_planner/features/auth/presentation/screens/phone_verify_screen.dart';
import 'package:pesa_planner/features/auth/presentation/screens/register_screen.dart';
import 'package:pesa_planner/features/budget/presentation/screens/budget_creation_screen.dart';
import 'package:pesa_planner/features/budget/presentation/screens/budget_list_screen.dart';
import 'package:pesa_planner/features/dashboard/home_screen.dart';
import 'package:pesa_planner/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:pesa_planner/features/expenses/presentation/screens/expense_dashboard.dart';
import 'package:pesa_planner/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:pesa_planner/features/mpesa/presentation/screens/mpesa_history_screen.dart';
import 'package:pesa_planner/features/mpesa/presentation/screens/mpesa_payment_screen.dart';
import 'package:pesa_planner/features/reports/presentation/screens/report_generation_screen.dart';
import 'package:pesa_planner/features/transport/presentation/screens/saved_routes_screen.dart';
import 'package:pesa_planner/features/transport/presentation/screens/transport_calculator_screen.dart';
import 'package:pesa_planner/features/transport/presentation/screens/transport_dashboard.dart';
import 'package:pesa_planner/features/utilities/presentation/screens/kplc_bill_list_screen.dart';
import 'package:pesa_planner/features/utilities/presentation/screens/kplc_bills_screen.dart';
import 'package:pesa_planner/features/utilities/presentation/screens/utilities_dashboard.dart';

class AppRouter {
  static Null get context => null;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Authentication Routes
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/phone-verify':
        return MaterialPageRoute(builder: (_) => const PhoneVerifyScreen());

      // Budget Routes
      case '/budgets':
        return MaterialPageRoute(builder: (_) => const BudgetListScreen());
      case '/create-budget':
        return MaterialPageRoute(builder: (_) => const BudgetCreationScreen());

      // Expense Routes
      case '/expenses':
        return MaterialPageRoute(builder: (_) => const ExpenseListScreen());
      case '/add-expense':
        return MaterialPageRoute(builder: (_) => const AddExpenseScreen());
      case '/expense-dashboard':
        return MaterialPageRoute(builder: (_) => const ExpenseDashboard());

      // Transport Routes
      case '/transport-calculator':
        return MaterialPageRoute(
          builder: (_) => const TransportCalculatorScreen(),
        );
      case '/saved-routes':
        return MaterialPageRoute(builder: (_) => const SavedRoutesScreen());
      case '/transport-dashboard':
        return MaterialPageRoute(builder: (_) => const TransportDashboard());

      // Utilities Routes
      case '/utilities':
        return MaterialPageRoute(builder: (_) => const UtilitiesDashboard());
      case '/kplc-bills':
        return MaterialPageRoute(builder: (_) => const KPLCBillListScreen());
      case '/add-kplc-bill':
        return MaterialPageRoute(builder: (_) => const KPLCBillsScreen());

      // M-PESA Routes
      case '/mpesa-payment':
        return MaterialPageRoute(builder: (_) => const MpesaPaymentScreen());
      case '/mpesa-history':
        return MaterialPageRoute(builder: (_) => const MpesaHistoryScreen());

      // Reports Routes
      case '/reports':
        return MaterialPageRoute(
          builder: (_) => const ReportGenerationScreen(),
        );

      // Default route for unknown paths
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Page Not Found',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The page "${settings.name}" doesn\'t exist',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/'),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

// Removed redundant and unused 'context' declarations

class MpesaHistoryScreen extends StatelessWidget {
  const MpesaHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('M-PESA History')),
      body: const Center(child: Text('M-PESA History Screen')),
    );
  }
}

class MpesaPaymentScreen extends StatelessWidget {
  const MpesaPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('M-PESA Payment')),
      body: const Center(child: Text('M-PESA Payment Screen')),
    );
  }
}

class KPLCBillsScreen extends StatelessWidget {
  const KPLCBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add KPLC Bill')),
      body: const Center(child: Text('Add KPLC Bill Screen')),
    );
  }
}

class KPLCBillListScreen extends StatelessWidget {
  const KPLCBillListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KPLC Bill List')),
      body: const Center(child: Text('KPLC Bill List Screen')),
    );
  }
}

class UtilitiesDashboard extends StatelessWidget {
  const UtilitiesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utilities Dashboard')),
      body: const Center(child: Text('Utilities Dashboard Screen')),
    );
  }
}
