import 'package:flutter/material.dart';
import 'package:pesa_planner/core/routes/app_router.dart';
import 'package:pesa_planner/core/theme/app_theme.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          // Handle authentication state
          Widget homeScreen;

          if (!authService.isInitialized) {
            // Show splash screen while initializing
            homeScreen = const SplashScreen();
          } else if (authService.currentUser == null) {
            // Redirect to login if not authenticated
            homeScreen = const LoginScreen();
          } else {
            // Go to home screen if authenticated
            homeScreen = const HomeScreen();
          }

          return MaterialApp(
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
