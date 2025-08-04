import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pesa_planner/app_widget.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [Provider<AuthService>(create: (_) => AuthService())],
      child: const AppWidget(),
    ),
  );
}
