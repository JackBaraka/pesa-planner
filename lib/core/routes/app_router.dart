import 'package:flutter/material.dart';
import 'package:pesa_planner/features/auth/presentation/screens/login_screen.dart';
import 'package:pesa_planner/features/auth/presentation/screens/phone_verify_screen.dart';
import 'package:pesa_planner/features/budget/presentation/screens/budget_creation_screen.dart';
import 'package:pesa_planner/features/budget/presentation/screens/budget_list_screen.dart';
import 'package:pesa_planner/features/dashboard/home_screen.dart';
import 'package:pesa_planner/features/expenses/presentation/screens/add_expense_screen.dart'
    show AddExpenseScreen;
import 'package:pesa_planner/features/expenses/presentation/screens/expense_dashboard.dart'
    show ExpenseDashboard;
import 'package:pesa_planner/features/expenses/presentation/screens/expense_list_screen.dart'
    show ExpenseListScreen;

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/phone-verify':
        return MaterialPageRoute(builder: (_) => const PhoneVerifyScreen());
      case '/budgets':
        return MaterialPageRoute(builder: (_) => const BudgetListScreen());
      case '/create-budget':
        return MaterialPageRoute(builder: (_) => const BudgetCreationScreen());
      // Add these routes to your existing AppRouter class
      case '/expenses':
        return MaterialPageRoute(builder: (_) => const ExpenseListScreen());
      case '/add-expense':
        return MaterialPageRoute(builder: (_) => const AddExpenseScreen());
      case '/expense-dashboard':
        return MaterialPageRoute(builder: (_) => const ExpenseDashboard());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

class RegisterScreen {
  const RegisterScreen();
}
