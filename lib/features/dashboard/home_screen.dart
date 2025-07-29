import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/routes/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesa Planner'),
        backgroundColor: AppColors.kenyaGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Provider.of<AuthService>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.money,
            title: 'Budgets',
            subtitle: 'Create and manage your budgets',
            route: '/budgets',
          ),
          _buildFeatureCard(
            context,
            icon: Icons.receipt,
            title: 'Expenses',
            subtitle: 'Track your daily expenses',
            route: '/expenses',
          ),
          _buildFeatureCard(
            context,
            icon: Icons.lightbulb,
            title: 'KPLC Bills',
            subtitle: 'Track and pay electricity bills',
            route: '/kplc',
          ),
          _buildFeatureCard(
            context,
            icon: Icons.directions_bus,
            title: 'Transport',
            subtitle: 'Track matatu and Uber costs',
            route: '/transport',
          ),
          _buildFeatureCard(
            context,
            icon: Icons.bar_chart,
            title: 'Reports',
            subtitle: 'View monthly financial reports',
            route: '/reports',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-budget'),
        backgroundColor: AppColors.kenyaGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 40, color: AppColors.kenyaGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
