import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaystackCheckoutPage extends StatefulWidget {
  final String authorizationUrl; // Paystack Payment URL
  PaystackCheckoutPage({required this.authorizationUrl});

  @override
  _PaystackCheckoutPageState createState() => _PaystackCheckoutPageState();
}

class _PaystackCheckoutPageState extends State<PaystackCheckoutPage> {
  late InAppWebViewController _webViewController;

  // Verify the transaction
  Future<void> _verifyTransaction(String reference) async {
    const String paystackSecretKey = "sk_test_c599f90e335f16e09087861eebfaf074fdda3a26"; // Replace with your secret key
    final url = "https://api.paystack.co/transaction/verify/$reference";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $paystackSecretKey'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data']['status'] == 'success') {
          _showSuccessDialog(data['data']);
        } else {
          _showErrorDialog("Transaction Failed");
        }
      } else {
        _showErrorDialog("Error verifying transaction: ${response.body}");
      }
    } catch (e) {
      _showErrorDialog("Network Error: $e");
    }
  }

  // Show success dialog
  void _showSuccessDialog(Map<String, dynamic> transactionData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Payment Successful"),
          content: Text("Reference: ${transactionData['reference']}\n"
              "Amount: ${transactionData['amount'] / 100} NGN\n"
              "Status: ${transactionData['status']}"),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
        );
      },
    );
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paystack Checkout')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.authorizationUrl)),
        onLoadStop: (controller, url) {
          if (url != null && url.toString().contains("reference")) {
            // Extract reference from the URL
            Uri uri = Uri.parse(url.toString());
            String? reference = uri.queryParameters['reference'];
            if (reference != null) {
              _verifyTransaction(reference);
            }
          }
        },
        onReceivedError: (controller, request, error) {
          // Handle WebView errors
          _showErrorDialog("WebView Error: ${error.description}");
        },
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
      ),
    );
  }
}
