import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesa_planner/data/models/transport_model.dart';

class TransportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add transport route
  Future<void> addRoute(String userId, TransportRoute route) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transport_routes')
        .doc(route.id)
        .set(route.toMap());
  }

  // Get all transport routes for a user
  Stream<List<TransportRoute>> getRoutes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transport_routes')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransportRoute.fromMap(doc.data());
          }).toList();
        });
  }

  // Toggle favorite status
  Future<void> toggleFavorite(
    String userId,
    String routeId,
    bool isFavorite,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transport_routes')
        .doc(routeId)
        .update({'isFavorite': isFavorite});
  }

  // Delete route
  Future<void> deleteRoute(String userId, String routeId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transport_routes')
        .doc(routeId)
        .delete();
  }
}
