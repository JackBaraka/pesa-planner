﻿import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pesa_planner/app_widget.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AppWidget());
}
