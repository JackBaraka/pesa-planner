import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pesa_planner/app_widget.dart';
import 'package:pesa_planner/services/database_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize error handling
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      print('Flutter Error: ${details.exception}');
    };

    // Platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      print('Platform Error: $error');
      return true;
    };

    runApp(const AppWidget());
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Fallback UI for when Firebase fails
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'App Initialization Failed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Error: $e'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
