import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/utils/currency_formatter.dart';
import 'package:pesa_planner/data/models/transport_model.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/transport_service.dart';
import 'package:provider/provider.dart';

class SavedRoutesScreen extends StatelessWidget {
  const SavedRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context).currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view saved routes')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Transport Routes'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: StreamBuilder<List<TransportRoute>>(
        stream: Provider.of<TransportService>(context).getRoutes(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final routes = snapshot.data ?? [];

          if (routes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_bus,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text('No saved routes yet'),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/transport-calculator'),
                    child: const Text('Add your first route'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return _buildRouteCard(context, route, userId);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/transport-calculator'),
        backgroundColor: AppColors.kenyaGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context,
    TransportRoute route,
    String userId,
  ) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: const Icon(Icons.route, color: AppColors.kenyaGreen),
        title: Text(route.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${route.origin} → ${route.destination}'),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildFareChip('Matatu', route.matatuFare),
                const SizedBox(width: 8),
                if (route.uberFare > 0) _buildFareChip('Uber', route.uberFare),
                if (route.bodaFare > 0) ...[
                  const SizedBox(width: 8),
                  _buildFareChip('Boda', route.bodaFare),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                route.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: route.isFavorite ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(context, userId, route),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteRoute(context, userId, route.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareChip(String label, double fare) {
    return Chip(
      label: Text('$label: ${formatKSH(fare)}'),
      backgroundColor: AppColors.kenyaGreen.withOpacity(0.1),
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  void _toggleFavorite(
    BuildContext context,
    String userId,
    TransportRoute route,
  ) {
    final newFavoriteStatus = !route.isFavorite;
    Provider.of<TransportService>(
      context,
      listen: false,
    ).toggleFavorite(userId, route.id, newFavoriteStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${route.name} ${newFavoriteStatus ? 'favorited' : 'unfavorited'}',
        ),
      ),
    );
  }

  void _deleteRoute(BuildContext context, String userId, String routeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: const Text('Are you sure you want to delete this route?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TransportService>(
                context,
                listen: false,
              ).deleteRoute(userId, routeId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
