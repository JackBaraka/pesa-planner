import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pesa_planner/data/models/mpesa_transaction_model.dart';

class MpesaService {
  static const String _sandboxBaseUrl = 'https://sandbox.safaricom.co.ke';
  static const String _productionBaseUrl = 'https://api.safaricom.co.ke';

  String _accessToken = '';
  DateTime _tokenExpiry = DateTime.now();
  bool _isSandbox = true; // Change to false for production

  String get _baseUrl => _isSandbox ? _sandboxBaseUrl : _productionBaseUrl;

  // Get access token from Safaricom API
  Future<String?> _getAccessToken() async {
    if (_accessToken.isNotEmpty && DateTime.now().isBefore(_tokenExpiry)) {
      return _accessToken;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
        headers: {
          'Authorization': 'Basic ${_getBase64Credentials()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(
          Duration(seconds: data['expires_in'] ?? 3600),
        );
        return _accessToken;
      } else {
        throw Exception('Failed to get access token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting access token: $e');
    }
  }

  // Base64 encode consumer key and secret
  String _getBase64Credentials() {
    const consumerKey = 'YOUR_CONSUMER_KEY'; // Replace with your actual key
    const consumerSecret =
        'YOUR_CONSUMER_SECRET'; // Replace with your actual secret
    final credentials = '$consumerKey:$consumerSecret';
    return base64Encode(utf8.encode(credentials));
  }

  // STK Push for Lipa Na M-PESA
  Future<Map<String, dynamic>> initiateSTKPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String description,
  }) async {
    try {
      final token = await _getAccessToken();
      final timestamp = _getTimestamp();
      final password = _getPassword(timestamp);

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "BusinessShortCode": _isSandbox
              ? "174379"
              : "YOUR_BUSINESS_SHORTCODE",
          "Password": password,
          "Timestamp": timestamp,
          "TransactionType": "CustomerPayBillOnline",
          "Amount": amount.toStringAsFixed(0),
          "PartyA": _formatPhoneNumber(phoneNumber),
          "PartyB": _isSandbox ? "174379" : "YOUR_BUSINESS_SHORTCODE",
          "PhoneNumber": _formatPhoneNumber(phoneNumber),
          "CallBackURL":
              "https://yourdomain.com/mpesa-callback", // Replace with your callback URL
          "AccountReference": accountReference,
          "TransactionDesc": description,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'checkoutRequestID': data['CheckoutRequestID'],
          'message': 'STK Push initiated successfully',
        };
      } else {
        return {'success': false, 'error': 'STK Push failed: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'STK Push error: $e'};
    }
  }

  // Paybill payment
  Future<Map<String, dynamic>> paybillPayment({
    required String phoneNumber,
    required double amount,
    required String paybillNumber,
    required String accountNumber,
    required String description,
  }) async {
    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/b2c/v1/paymentrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "InitiatorName": "YOUR_INITIATOR_NAME",
          "SecurityCredential": "YOUR_SECURITY_CREDENTIAL",
          "CommandID": "BusinessPayment",
          "Amount": amount.toStringAsFixed(0),
          "PartyA": "YOUR_SHORTCODE",
          "PartyB": paybillNumber,
          "Remarks": description,
          "QueueTimeOutURL": "https://yourdomain.com/timeout",
          "ResultURL": "https://yourdomain.com/result",
          "Occasion": "BillPayment",
          "AccountReference": accountNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'conversationId': data['ConversationID'],
          'message': 'Paybill payment initiated successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Paybill payment failed: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Paybill payment error: $e'};
    }
  }

  // Send money to phone number
  Future<Map<String, dynamic>> sendMoney({
    required String fromPhoneNumber,
    required String toPhoneNumber,
    required double amount,
    required String description,
  }) async {
    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/b2c/v1/paymentrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "InitiatorName": "YOUR_INITIATOR_NAME",
          "SecurityCredential": "YOUR_SECURITY_CREDENTIAL",
          "CommandID": "BusinessPayment",
          "Amount": amount.toStringAsFixed(0),
          "PartyA": "YOUR_SHORTCODE",
          "PartyB": _formatPhoneNumber(toPhoneNumber),
          "Remarks": description,
          "QueueTimeOutURL": "https://yourdomain.com/timeout",
          "ResultURL": "https://yourdomain.com/result",
          "Occasion": "MoneyTransfer",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'conversationId': data['ConversationID'],
          'message': 'Money sent successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Send money failed: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Send money error: $e'};
    }
  }

  // Check transaction status
  Future<Map<String, dynamic>> checkTransactionStatus(
    String transactionId,
  ) async {
    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/transactionstatus/v1/query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "Initiator": "YOUR_INITIATOR_NAME",
          "SecurityCredential": "YOUR_SECURITY_CREDENTIAL",
          "CommandID": "TransactionStatusQuery",
          "TransactionID": transactionId,
          "PartyA": "YOUR_SHORTCODE",
          "IdentifierType": "1",
          "ResultURL": "https://yourdomain.com/result",
          "QueueTimeOutURL": "https://yourdomain.com/timeout",
          "Remarks": "Transaction Status Query",
          "Occasion": "TransactionStatus",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Transaction status retrieved',
        };
      } else {
        return {
          'success': false,
          'error': 'Status check failed: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Status check error: $e'};
    }
  }

  // Helper methods
  String _getTimestamp() {
    final now = DateTime.now().toUtc();
    return now.toString().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 14);
  }

  String _getPassword(String timestamp) {
    const businessShortCode = "174379"; // Sandbox shortcode
    const passkey = "YOUR_PASSKEY"; // Replace with your actual passkey
    final password = '$businessShortCode$passkey$timestamp';
    return base64Encode(utf8.encode(password));
  }

  String _formatPhoneNumber(String phoneNumber) {
    // Convert 07xxxxxxxx to 2547xxxxxxxx
    if (phoneNumber.startsWith('07')) {
      return '254${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('01')) {
      return '254${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('254')) {
      return phoneNumber;
    } else {
      return phoneNumber; // Return as is if format is unknown
    }
  }

  // Simulate M-PESA transaction (for testing without actual API calls)
  Future<Map<String, dynamic>> simulateMpesaTransaction({
    required String transactionType,
    required double amount,
    required String phoneNumber,
    required String accountNumber,
    String? description,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate success 80% of the time for testing
    final isSuccess = DateTime.now().millisecond % 5 != 0;

    if (isSuccess) {
      return {
        'success': true,
        'transactionId': 'MPE${DateTime.now().millisecondsSinceEpoch}',
        'conversationId': 'CONV${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Transaction completed successfully',
        'data': {'ResponseCode': '0', 'ResponseDescription': 'Success'},
      };
    } else {
      return {
        'success': false,
        'error': 'Transaction failed: Insufficient funds',
        'data': {'ResponseCode': '1', 'ResponseDescription': 'Failed'},
      };
    }
  }
}
