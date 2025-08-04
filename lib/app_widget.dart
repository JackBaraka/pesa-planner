import 'package:flutter/material.dart';
import 'package:pesa_planner/core/routes/app_router.dart';
import 'package:pesa_planner/core/theme/app_theme.dart';
import 'package:pesa_planner/data/models/user_model.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: Consumer<AuthService>(
        builder: (context, auth, child) {
          return StreamProvider<AppUser?>(
            create: (context) => auth.user,
            initialData: null,
            child: MaterialApp(
              title: 'Pesa Planner',
              theme: kenyanTheme,
              debugShowCheckedModeBanner: false,
              initialRoute: '/',
              onGenerateRoute: AppRouter.generateRoute,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
