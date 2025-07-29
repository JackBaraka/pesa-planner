import 'package:flutter/material.dart';
import 'package:pesa_planner/core/theme/app_colors.dart';
import 'package:pesa_planner/core/utils/currency_formatter.dart';
import 'package:pesa_planner/data/models/transport_model.dart';
import 'package:pesa_planner/services/auth_service.dart';
import 'package:pesa_planner/services/transport_service.dart';
import 'package:provider/provider.dart';

class TransportCalculatorScreen extends StatefulWidget {
  const TransportCalculatorScreen({super.key});

  @override
  State<TransportCalculatorScreen> createState() =>
      _TransportCalculatorScreenState();
}

class _TransportCalculatorScreenState extends State<TransportCalculatorScreen> {
  TransportRoute? _selectedRoute;
  int _tripsPerDay = 2;
  int _daysPerWeek = 5;
  double _totalCost = 0.0;
  String _selectedMode = 'matatu';

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context).currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to use transport calculator')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Cost Calculator'),
        backgroundColor: AppColors.kenyaGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRouteSelector(),
              const SizedBox(height: 24),
              _buildTransportModeSelector(),
              const SizedBox(height: 24),
              _buildTripInputs(),
              const SizedBox(height: 24),
              _buildCostSummary(),
              const SizedBox(height: 24),
              if (_selectedRoute != null) _buildSaveRouteButton(userId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Route',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TransportRoute.kenyanRoutes.map((route) {
                return ChoiceChip(
                  label: Text(route.name),
                  selected: _selectedRoute?.id == route.id,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRoute = selected ? route : null;
                      _calculateCost();
                    });
                  },
                  selectedColor: AppColors.kenyaGreen.withOpacity(0.3),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (_selectedRoute != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Fares for ${_selectedRoute!.name}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Matatu:'),
                      Text(formatKSH(_selectedRoute!.matatuFare)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Uber/Bolt:'),
                      Text(formatKSH(_selectedRoute!.uberFare)),
                    ],
                  ),
                  if (_selectedRoute!.bodaFare > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Boda Boda:'),
                        Text(formatKSH(_selectedRoute!.bodaFare)),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportModeSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Transport Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Matatu'),
                    leading: Radio(
                      value: 'matatu',
                      groupValue: _selectedMode,
                      onChanged: (value) {
                        setState(() {
                          _selectedMode = value.toString();
                          _calculateCost();
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Uber/Bolt'),
                    leading: Radio(
                      value: 'uber',
                      groupValue: _selectedMode,
                      onChanged: (value) {
                        setState(() {
                          _selectedMode = value.toString();
                          _calculateCost();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedRoute?.bodaFare > 0)
              ListTile(
                title: const Text('Boda Boda'),
                leading: Radio(
                  value: 'boda',
                  groupValue: _selectedMode,
                  onChanged: (value) {
                    setState(() {
                      _selectedMode = value.toString();
                      _calculateCost();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInputs() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Frequency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Trips per day:'),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _tripsPerDay.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _tripsPerDay.toString(),
                    onChanged: (value) {
                      setState(() {
                        _tripsPerDay = value.toInt();
                        _calculateCost();
                      });
                    },
                    activeColor: AppColors.kenyaGreen,
                  ),
                ),
                Text('$_tripsPerDay'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Days per week:'),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _daysPerWeek.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    label: _daysPerWeek.toString(),
                    onChanged: (value) {
                      setState(() {
                        _daysPerWeek = value.toInt();
                        _calculateCost();
                      });
                    },
                    activeColor: AppColors.kenyaGreen,
                  ),
                ),
                Text('$_daysPerWeek'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSummary() {
    return Card(
      elevation: 4,
      color: AppColors.kenyaGreen.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cost Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_selectedRoute == null)
              const Center(child: Text('Select a route to calculate costs'))
            else
              Column(
                children: [
                  _buildCostRow('Daily Cost', _calculateDailyCost()),
                  _buildCostRow('Weekly Cost', _calculateWeeklyCost()),
                  _buildCostRow('Monthly Cost', _calculateMonthlyCost()),
                  _buildCostRow('Yearly Cost', _calculateYearlyCost()),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            formatKSH(amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveRouteButton(String userId) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _saveRoute(userId),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kenyaGreen,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        child: const Text('SAVE THIS ROUTE'),
      ),
    );
  }

  void _calculateCost() {
    if (_selectedRoute == null) {
      setState(() => _totalCost = 0.0);
      return;
    }

    double fare;
    switch (_selectedMode) {
      case 'matatu':
        fare = _selectedRoute!.matatuFare;
        break;
      case 'uber':
        fare = _selectedRoute!.uberFare;
        break;
      case 'boda':
        fare = _selectedRoute!.bodaFare;
        break;
      default:
        fare = _selectedRoute!.matatuFare;
    }

    setState(() => _totalCost = fare);
  }

  double _calculateDailyCost() {
    return _totalCost * _tripsPerDay;
  }

  double _calculateWeeklyCost() {
    return _calculateDailyCost() * _daysPerWeek;
  }

  double _calculateMonthlyCost() {
    return _calculateWeeklyCost() * 4; // Approximate 4 weeks per month
  }

  double _calculateYearlyCost() {
    return _calculateMonthlyCost() * 12;
  }

  Future<void> _saveRoute(String userId) async {
    if (_selectedRoute == null) return;

    final route = _selectedRoute!;
    await Provider.of<TransportService>(
      context,
      listen: false,
    ).addRoute(userId, route);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${route.name} saved to your routes')),
    );
  }
}
