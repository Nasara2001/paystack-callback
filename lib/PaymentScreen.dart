import 'package:flutter/material.dart';
import 'package:paystack_app/paystack_service.dart';

import 'PaystackCheckoutPage.dart';


class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Future<void> _initiatePayment() async {
    String email = 'customer@example.com'; // Replace with actual customer email
    int amount = 20000; // Replace with the amount you want to charge in kobo

    String? authorizationUrl = await initializeTransaction(email, amount);
    if (authorizationUrl != null) {
      // Navigate to the Paystack Checkout WebView
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaystackCheckoutPage(authorizationUrl: authorizationUrl),
        ),
      );
    } else {
      // Handle failure to initialize the transaction
      print("Failed to initialize transaction");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _initiatePayment,
          child: Text('Pay with Paystack'),
        ),
      ),
    );
  }
}