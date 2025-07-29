class TransportRoute {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final double matatuFare;
  final double uberFare;
  final double bodaFare;
  final bool isFavorite;

  TransportRoute({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.matatuFare,
    required this.uberFare,
    required this.bodaFare,
    this.isFavorite = false,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'destination': destination,
      'matatuFare': matatuFare,
      'uberFare': uberFare,
      'bodaFare': bodaFare,
      'isFavorite': isFavorite,
    };
  }

  // Create TransportRoute from Firestore map
  factory TransportRoute.fromMap(Map<String, dynamic> map) {
    return TransportRoute(
      id: map['id'],
      name: map['name'],
      origin: map['origin'],
      destination: map['destination'],
      matatuFare: map['matatuFare'].toDouble(),
      uberFare: map['uberFare'].toDouble(),
      bodaFare: map['bodaFare'].toDouble(),
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  // Kenyan popular routes
  static List<TransportRoute> kenyanRoutes = [
    TransportRoute(
      id: 'cbd-westlands',
      name: 'CBD to Westlands',
      origin: 'Nairobi CBD',
      destination: 'Westlands',
      matatuFare: 100.0,
      uberFare: 300.0,
      bodaFare: 150.0,
    ),
    TransportRoute(
      id: 'cbd-karen',
      name: 'CBD to Karen',
      origin: 'Nairobi CBD',
      destination: 'Karen',
      matatuFare: 120.0,
      uberFare: 450.0,
      bodaFare: 250.0,
    ),
    TransportRoute(
      id: 'cbd-thika',
      name: 'CBD to Thika',
      origin: 'Nairobi CBD',
      destination: 'Thika',
      matatuFare: 150.0,
      uberFare: 800.0,
      bodaFare: 0.0, // Not common
    ),
    TransportRoute(
      id: 'westlands-karen',
      name: 'Westlands to Karen',
      origin: 'Westlands',
      destination: 'Karen',
      matatuFare: 80.0,
      uberFare: 350.0,
      bodaFare: 200.0,
    ),
  ];
}
