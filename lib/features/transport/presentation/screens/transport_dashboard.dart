import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/utils/currency_formatter.dart';
import 'package:pesa_planner/data/models/transport_model.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/transport_service.dart';
import 'package:provider/provider.dart';

class TransportDashboard extends StatelessWidget {
  const TransportDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context).currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view transport dashboard')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Dashboard'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: StreamBuilder<List<TransportRoute>>(
        stream: Provider.of<TransportService>(context).getRoutes(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
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
                  const Text('No transport data available'),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/transport-calculator'),
                    child: const Text('Add your first route'),
                  ),
                ],
              ),
            );
          }

          final routes = snapshot.data!;
          final favoriteRoutes = routes.where((r) => r.isFavorite).toList();

          return Column(
            children: [
              if (favoriteRoutes.isNotEmpty)
                _buildFavoriteRoutes(favoriteRoutes),
              Expanded(
                child: ListView.builder(
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return _buildRouteCard(route);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFavoriteRoutes(List<TransportRoute> favoriteRoutes) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Favorite Routes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: favoriteRoutes.length,
              itemBuilder: (context, index) {
                final route = favoriteRoutes[index];
                return _buildFavoriteCard(route);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(TransportRoute route) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      color: AppColors.kenyaGreen.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Matatu: ${formatKSH(route.matatuFare)}',
                style: const TextStyle(fontSize: 14),
              ),
              if (route.uberFare > 0)
                Text(
                  'Uber: ${formatKSH(route.uberFare)}',
                  style: const TextStyle(fontSize: 14),
                ),
              if (route.bodaFare > 0)
                Text(
                  'Boda: ${formatKSH(route.bodaFare)}',
                  style: const TextStyle(fontSize: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(TransportRoute route) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.route, color: route.isFavorite ? Colors.red : null),
        title: Text(route.name),
        subtitle: Text('${route.origin} → ${route.destination}'),
        trailing: Text(formatKSH(route.matatuFare)),
        onTap: () {
          // Navigate to calculator with this route pre-selected
        },
      ),
    );
  }
}
