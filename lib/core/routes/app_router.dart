import 'package:flutter/material.dart';
import 'package:pesa_planner/features/auth/presentation/screens/login_screen.dart';
import 'package:pesa_planner/features/auth/presentation/screens/phone_verify_screen.dart';
import 'package:pesa_planner/features/budget/presentation/screens/budget_creation_screen.dart';
import 'package:pesa_planner/features/budget/presentation/screens/budget_list_screen.dart';
import 'package:pesa_planner/features/dashboard/home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/phone-verify':
        return MaterialPageRoute(builder: (_) => const PhoneVerifyScreen());
      case '/budgets':
        return MaterialPageRoute(builder: (_) => const BudgetListScreen());
      case '/create-budget':
        return MaterialPageRoute(builder: (_) => const BudgetCreationScreen());
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
