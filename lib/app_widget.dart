import 'package:flutter/material.dart';
import 'package:pesa_planner/core/routes/app_router.dart';
import 'package:pesa_planner/core/theme/app_theme.dart';
import 'package:pesa_planner/features/auth/presentation/screens/login_screen.dart'
    show LoginScreen;
import 'package:pesa_planner/features/dashboard/home_screen.dart'
    show HomeScreen;
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/database_service.dart';
import 'package:pesa_planner/services/expense_service.dart';
import 'package:pesa_planner/services/mpesa_transaction_service.dart';
import 'package:pesa_planner/services/transport_service.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<ExpenseService>(create: (_) => ExpenseService()),
        Provider<TransportService>(create: (_) => TransportService()),
        Provider<MpesaTransactionService>(
          create: (_) => MpesaTransactionService(),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          Widget homeScreen;

          if (!authService.isInitialized) {
            homeScreen = const SplashScreen();
          } else if (authService.currentUser == null) {
            homeScreen = const LoginScreen();
          } else {
            homeScreen = const HomeScreen();
          }

          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Pesa Planner',
            theme: kenyanTheme,
            debugShowCheckedModeBanner: false,
            home: homeScreen,
            onGenerateRoute: AppRouter.generateRoute,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
