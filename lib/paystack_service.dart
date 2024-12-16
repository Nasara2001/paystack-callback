// paystack_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> initializeTransaction(String email, int amount) async {
  const String paystackSecretKey = "sk_test_c599f90e335f16e09087861eebfaf074fdda3a26"; // Replace with your secret key
  const String url = "https://api.paystack.co/transaction/initialize";

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $paystackSecretKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": email,
        "amount": amount, // in kobo (e.g., 20000 = ₦200)
        "callback_url": "https://hello.pstk.xyz/callback", // Add your callback URL
        "metadata": {
          "cancel_action": "https://your-cancel-url.com" // URL for cancel actions
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['authorization_url']; // Return the Paystack checkout URL
    } else {
      print("Error: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Exception: $e");
    return null;
  }
}


Future<Map<String, dynamic>?> verifyTransaction(String reference) async {
  const String paystackSecretKey = "sk_test_c599f90e335f16e09087861eebfaf074fdda3a26"; // Replace with your secret key
  final String url = "https://api.paystack.co/transaction/verify/$reference";

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $paystackSecretKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // Return transaction details
    } else {
      print("Error verifying transaction: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Exception: $e");
    return null;
  }
}
