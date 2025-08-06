import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/utils/currency_formatter.dart';
import 'package:pesa_planner/data/models/transport_model.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  // ... your existing state variables ...

  void _showAddRouteDialog(BuildContext context) {}

  // ... rest of your existing methods ...
  String _selectedRouteType = 'matatu';
  String _searchQuery = '';
  List<TransportRoute> _filteredRoutes = [];

  @override
  void initState() {
    super.initState();
    _filteredRoutes = TransportRoute.kenyanRoutes;
  }

  void _filterRoutes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredRoutes = TransportRoute.kenyanRoutes;
      } else {
        _filteredRoutes = TransportRoute.kenyanRoutes.where((route) {
          return route.name.toLowerCase().contains(query.toLowerCase()) ||
              route.origin.toLowerCase().contains(query.toLowerCase()) ||
              route.destination.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleFavorite(TransportRoute route) {
    setState(() {
      final index = TransportRoute.kenyanRoutes.indexWhere(
        (r) => r.id == route.id,
      );
      if (index != -1) {
        TransportRoute.kenyanRoutes[index] = route.copyWith(
          isFavorite: !route.isFavorite,
        );
        _filterRoutes(_searchQuery); // Refresh filtered list
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kenyan Transport Costs'),
        backgroundColor: AppColors.kenyaGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_road),
            onPressed: () => _showAddRouteDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search routes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterRoutes,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTransportTypeChip('Matatu', Icons.directions_bus),
                _buildTransportTypeChip('Uber/Bolt', Icons.directions_car),
                _buildTransportTypeChip('Boda', Icons.motorcycle),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredRoutes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_off,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('No routes found'),
                        Text('Try a different search term'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredRoutes.length,
                    itemBuilder: (context, index) {
                      return _buildRouteCard(_filteredRoutes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportTypeChip(String label, IconData icon) {
    final isSelected = _selectedRouteType == label.toLowerCase();
    return ChoiceChip(
      label: Row(
        children: [Icon(icon, size: 18), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      selectedColor: AppColors.kenyaGreen.withOpacity(0.2),
      onSelected: (selected) {
        setState(() {
          _selectedRouteType = label.toLowerCase();
        });
      },
    );
  }

  Widget _buildRouteCard(TransportRoute route) {
    double fare;
    switch (_selectedRouteType) {
      case 'uber':
        fare = route.uberFare;
        break;
      case 'boda':
        fare = route.bodaFare;
        break;
      default:
        fare = route.matatuFare;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: InkWell(
        onTap: () => _showRouteDetails(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      route.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      route.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: route.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorite(route),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${route.origin} to ${route.destination}'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimated Fare',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatKSH(fare),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.kenyaGreen,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      _buildFareComparison('Matatu', route.matatuFare),
                      _buildFareComparison('Uber', route.uberFare),
                      _buildFareComparison('Boda', route.bodaFare),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFareComparison(String type, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getTransportColor(type),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(type),
          const SizedBox(width: 8),
          Text(
            formatKSH(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getTransportColor(type),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransportColor(String type) {
    switch (type.toLowerCase()) {
      case 'uber':
        return Colors.blue;
      case 'boda':
        return Colors.orange;
      default:
        return AppColors.kenyaGreen;
    }
  }

  void _showRouteDetails(BuildContext context, TransportRoute route) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  route.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Origin', route.origin),
              _buildDetailRow('Destination', route.destination),
              const Divider(height: 30),
              _buildFareDetail(
                'Matatu Fare',
                route.matatuFare,
                Icons.directions_bus,
              ),
              _buildFareDetail(
                'Uber/Bolt Fare',
                route.uberFare,
                Icons.directions_car,
              ),
              _buildFareDetail('Boda Fare', route.bodaFare, Icons.motorcycle),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement navigation to expense tracking
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/add-expense',
                        arguments: {
                          'category': 'Transport',
                          'subCategory': route.name,
                          'amount': route.matatuFare,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kenyaGreen,
                    ),
                    child: const Text('Track This Expense'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildFareDetail(String label, double amount, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: _getTransportColor(label)),
      title: Text(label),
      trailing: Text(
        formatKSH(amount),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
