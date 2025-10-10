import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../logic/blocs/add_card/card_bloc.dart';
import '../logic/blocs/add_card/card_event.dart';


class PaymentService {
  Dio dio = Dio();

  /// Create Stripe Customer and store in Firestore
  Future<String?> createCustomerIfNotExists() async {
    try {
      final response = await dio.post(
        'https://api.stripe.com/v1/customers',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Dio already parses JSON, so directly access response.data
        final customerId = response.data['id'] as String;
        print("Customer created: $customerId");
        return customerId;
      }
    } catch (e) {
      print("Error creating customer: $e");
    }

    return null;
  }

  /// Create SetupIntent for saving card
  Future<Map<String, dynamic>?> createSetupIntent(String customerId) async {
    try {
      final response = await dio.post(
        'https://api.stripe.com/v1/setup_intents',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {
          'customer': customerId,
        },
      );

      if (response.statusCode == 200) {
        // Return response.data directly (already parsed)
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error creating setup intent: $e");
    }

    return null;
  }

  /// Save card using SetupIntent and store it in Firestore
  Future<void> saveCard(BuildContext context) async {
    try {
      final customerId = await createCustomerIfNotExists();
      if (customerId == null) {
        print("Failed to create customer");
        return;
      }

      final setupIntent = await createSetupIntent(customerId);
      if (setupIntent == null) {
        print("Failed to create setup intent");
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: setupIntent['client_secret'],
          merchantDisplayName: 'Evo Coffee',
          googlePay: const PaymentSheetGooglePay(
            testEnv: true,
            currencyCode: "INR",
            merchantCountryCode: "IN",
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      /// Fetch saved cards from Stripe
      final cards = await listSavedCards(customerId);

      // Use BLoC to add each card with duplicate check
      for (final card in cards) {
        context.read<CardBloc>().add(
          AddCardWithDuplicateCheck(
            cardData: card,
            customerId: customerId,
          ),
        );
      }

    } catch (e) {
      print("Error in saveCard: $e");
      // You can emit an error state here if needed
      context.read<CardBloc>().add(LoadCards()); // Refresh cards on error
    }
  }
  /// List saved payment methods (cards)
  Future<List<dynamic>> listSavedCards(String customerId) async {
    try {
      final response = await dio.get(
        'https://api.stripe.com/v1/payment_methods?customer=$customerId&type=card',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Return response.data['data'] directly
        return response.data['data'] as List<dynamic>;
      }
    } catch (e) {
      print("Error listing saved cards: $e");
    }

    return [];
  }

  /// Pay with saved card
  Future<bool> payWithSavedCard({
    required String paymentMethodId,
    required String customerId,
    required int amount,
  }) async {
    try {
      final response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {
          'amount': amount.toString(),
          'currency': 'inr',
          'customer': customerId,
          'payment_method': paymentMethodId,
          'off_session': 'true',
          'confirm': 'true',
        },
      );

      // Access response.data directly
      final data = response.data as Map<String, dynamic>;

      if (data['status'] == 'succeeded') {
        print("Payment succeeded!");
        return true;
      } else {
        print("Payment failed: ${data['error'] ?? 'Unknown error'}");
        return false;
      }
    } catch (e) {
      print("Error in payment: $e");
      return false;
    }
  }

  /// Get saved cards from Firestore for current user
  Future<List<Map<String, dynamic>>> getSavedCardsFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("card")
          .orderBy("create_date", descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print("Error getting saved cards: $e");
      return [];
    }
  }
}
// // Initialize Stripe with the publishable key
// static Future<void> initializeStripe() async {
//   if (kIsWeb) {
//     // Skip Stripe initialization for the web as flutter_stripe doesn't support web
//     print('Stripe is not supported for Web. Initialization skipped.');
//     return;
//   }
//
//   try {
//     final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
//
//     if (publishableKey == null || publishableKey.isEmpty) {
//       print("Stripe Publishable Key not found in .env");
//       throw Exception("Stripe Publishable Key not found in .env");
//     }
//
//     // Initialize Stripe with the publishable key
//     Stripe.publishableKey = publishableKey;
//
//     // Ensure Stripe is properly configured
//     await Stripe.instance.applySettings();
//
//     print(
//       "Stripe initialized successfully with publishable key: ${publishableKey.substring(0, 12)}...",
//     );
//   } catch (e) {
//     print('Error initializing Stripe: $e');
//     rethrow; // Re-throw to ensure app fails fast if Stripe can't be initialized
//   }
// }
//
// // Create a Payment Intent
// Future<Map<String, dynamic>?> createPaymentIntent(
//   String amount,
//   String currency,
// ) async {
//   try {
//     final body = {
//       'amount': calculateAmount(amount),
//       'currency': currency,
//       'payment_method_types[]': 'card',
//     };
//
//     final response = await _dio.post(
//       'https://api.stripe.com/v1/payment_intents',
//       options: Options(
//         headers: {
//           'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//       ),
//       data: body,
//     );
//
//     if (response.statusCode == 200) {
//       print('Payment intent created successfully: ${response.data}');
//       return response.data;
//     } else {
//       print('Failed to create payment intent: ${response.data}');
//       return null;
//     }
//   } catch (err) {
//     print('Error creating payment intent: $err');
//     return null;
//   }
// }
//
// // Calculate the amount to be charged (in cents)
// String calculateAmount(String amount) {
//   try {
//     return (int.parse(amount) * 100).toString();
//   } catch (e) {
//     print("Error calculating amount: $e");
//     throw Exception("Invalid amount provided.");
//   }
// }
//
// // Handle payment sheet
// Future<String?> displayPaymentSheet(
//   BuildContext context,
//   String clientSecret,
// ) async {
//   try {
//     print(
//       'Initializing payment sheet with client secret: ${clientSecret.substring(0, 20)}...',
//     );
//
//     await Stripe.instance.initPaymentSheet(
//       paymentSheetParameters: SetupPaymentSheetParameters(
//         paymentIntentClientSecret: clientSecret,
//         style: ThemeMode.light,
//         merchantDisplayName: 'Ashtra Salon',
//       ),
//     );
//     print('Payment sheet initialized successfully');
//
//     print('Presenting payment sheet...');
//     await Stripe.instance.presentPaymentSheet();
//     print('Payment sheet completed successfully');
//
//     // Retrieve payment intent and get paymentMethodId
//     final paymentIntent = await Stripe.instance.retrievePaymentIntent(
//       clientSecret,
//     );
//     final paymentMethodId = paymentIntent.paymentMethodId;
//     print('Stripe Payment Method ID: $paymentMethodId');
//
//     return paymentMethodId;
//   } catch (e) {
//     print('Error in displayPaymentSheet: $e');
//     return null;
//   }
// }

// Removed displaySaveCardSheet. Use the clientSecret from backend setup intent only.

// Removed _createSetupIntent. Always use the clientSecret from backend setup intent only.


class StripePaymentService{

}