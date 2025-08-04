import 'package:flutter/material.dart';
import 'package:pesa_planner/features/auth/presentation/screens/login_screen.dart';
import 'package:pesa_planner/features/auth/presentation/screens/phone_verify_screen.dart';
import 'package:pesa_planner/features/auth/presentation/screens/register_screen.dart'; // Added import
import 'package:pesa_planner/features/budget/presentation/screens/budget_creation_screen.dart';
import 'package:pesa_planner/features/budget/presentation/screens/budget_list_screen.dart';
import 'package:pesa_planner/features/dashboard/home_screen.dart';
import 'package:pesa_planner/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:pesa_planner/features/expenses/presentation/screens/expense_dashboard.dart';
import 'package:pesa_planner/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:pesa_planner/features/kplc/presentation/screens/kplc_bill_screen.dart'; // Added import
import 'package:pesa_planner/features/transport/presentation/screens/saved_routes_screen.dart';
import 'package:pesa_planner/features/transport/presentation/screens/transport_calculator_screen.dart';
import 'package:pesa_planner/features/transport/presentation/screens/transport_dashboard.dart';
import 'package:pesa_planner/features/transport/presentation/screens/transport_screen.dart';
import 'package:pesa_planner/features/utilities/presentation/screens/kplc_bill_screen.dart'; // Added import

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register': // Added route
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/phone-verify':
        return MaterialPageRoute(builder: (_) => const PhoneVerifyScreen());
      case '/budgets':
        return MaterialPageRoute(builder: (_) => const BudgetListScreen());
      case '/create-budget':
        return MaterialPageRoute(builder: (_) => const BudgetCreationScreen());
      case '/expenses':
        return MaterialPageRoute(builder: (_) => const ExpenseListScreen());
      case '/add-expense':
        return MaterialPageRoute(builder: (_) => const AddExpenseScreen());
      case '/expense-dashboard':
        return MaterialPageRoute(builder: (_) => const ExpenseDashboard());
      case '/transport': // ADDED MAIN TRANSPORT ROUTE
        return MaterialPageRoute(builder: (_) => const TransportScreen());
      case '/transport-calculator':
        return MaterialPageRoute(
          builder: (_) => const TransportCalculatorScreen(),
        );
      case '/saved-routes':
        return MaterialPageRoute(builder: (_) => const SavedRoutesScreen());
      case '/transport-dashboard':
        return MaterialPageRoute(builder: (_) => const TransportDashboard());
      case '/kplc': // Added route
        return MaterialPageRoute(builder: (_) => const KPLCBillScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
