import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class MpesaService with ChangeNotifier {
  static const String _baseUrl = 'https://sandbox.safaricom.co.ke';
  String _accessToken = '';
  DateTime _tokenExpiry = DateTime.now();
  final String consumerKey;
  final String consumerSecret;

  MpesaService({required this.consumerKey, required this.consumerSecret});

  Future<void> authenticate() async {
    try {
      final credentials = base64.encode(
        utf8.encode('$consumerKey:$consumerSecret'),
      );
      final response = await http.get(
        Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
        headers: {'Authorization': 'Basic $credentials'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(
          Duration(seconds: data['expires_in']),
        );
        notifyListeners();
      } else {
        throw Exception('Failed to authenticate with M-PESA API');
      }
    } catch (e) {
      throw Exception('M-PESA authentication error: $e');
    }
  }

  Future<bool> isAccessTokenValid() async {
    if (_accessToken.isEmpty || DateTime.now().isAfter(_tokenExpiry)) {
      await authenticate();
    }
    return _accessToken.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> fetchTransactions(
    String phoneNumber,
  ) async {
    if (!await isAccessTokenValid()) {
      throw Exception('M-PESA authentication failed');
    }

    try {
      // Format phone number (ensure it starts with 254)
      String formattedPhone = phoneNumber;
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '254${formattedPhone.substring(1)}';
      } else if (!formattedPhone.startsWith('254')) {
        formattedPhone = '254$formattedPhone';
      }

      // In a real implementation, this would call the M-PESA API
      // For now, we'll return mock data
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Mock transaction data
      return [
        {
          'id': '1',
          'type': 'Received',
          'amount': 1500.0,
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'sender': 'John Doe',
          'reference': 'Payment for services',
          'phone': formattedPhone,
        },
        {
          'id': '2',
          'type': 'Sent',
          'amount': 500.0,
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'recipient': 'Jane Smith',
          'reference': 'Shopping',
          'phone': formattedPhone,
        },
        {
          'id': '3',
          'type': 'Received',
          'amount': 2500.0,
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'sender': 'ABC Company',
          'reference': 'Salary',
          'phone': formattedPhone,
        },
      ];
    } catch (e) {
      throw Exception('Failed to fetch M-PESA transactions: $e');
    }
  }

  Future<Map<String, dynamic>> sendMoney({
    required String phone,
    required double amount,
    required String reference,
  }) async {
    if (!await isAccessTokenValid()) {
      throw Exception('M-PESA authentication failed');
    }

    try {
      // Format phone number
      String formattedPhone = phone;
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '254${formattedPhone.substring(1)}';
      } else if (!formattedPhone.startsWith('254')) {
        formattedPhone = '254$formattedPhone';
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 3));

      // Return mock response
      return {
        'success': true,
        'transactionId': 'MPE${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Transaction initiated successfully',
        'amount': amount,
        'recipient': formattedPhone,
      };
    } catch (e) {
      throw Exception('Failed to send money: $e');
    }
  }

  Future<Map<String, dynamic>> buyAirtime({
    required String phone,
    required double amount,
  }) async {
    if (!await isAccessTokenValid()) {
      throw Exception('M-PESA authentication failed');
    }

    try {
      // Format phone number
      String formattedPhone = phone;
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '254${formattedPhone.substring(1)}';
      } else if (!formattedPhone.startsWith('254')) {
        formattedPhone = '254$formattedPhone';
      }

      // Simulate API call
      await Future.delapsed(const Duration(seconds: 2));

      // Return mock response
      return {
        'success': true,
        'transactionId': 'AIR${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Airtime purchase successful',
        'amount': amount,
        'phone': formattedPhone,
      };
    } catch (e) {
      throw Exception('Failed to buy airtime: $e');
    }
  }
}
