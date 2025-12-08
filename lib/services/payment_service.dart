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

  /// Get current user's details from Firebase
  Future<Map<String, String>> _getCurrentUserDetails() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return <String, String>{
          'name': 'Guest User',
          'email': 'guest@example.com',
          'phone': '',
        };
      }

      final DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final Map<String, dynamic>? userData = userDoc.data();

      return <String, String>{
        'name': userData?['name'] ?? userData?['displayName'] ?? currentUser.displayName ?? 'User',
        'email': userData?['email'] ?? currentUser.email ?? 'user@example.com',
        'phone': userData?['phone'] ?? userData?['phoneNumber'] ?? currentUser.phoneNumber ?? '',
      };
    } catch (e) {
      print('Error getting user details: $e');
      return <String, String>{
        'name': 'User',
        'email': 'user@example.com',
        'phone': '',
      };
    }
  }

  /// Create Stripe Customer with user details and store in Firestore
  Future<String?> createCustomerIfNotExists() async {
    try {
      final Map<String, String> userDetails = await _getCurrentUserDetails();

      final Response<dynamic> response = await dio.post(
        'https://api.stripe.com/v1/customers',
        options: Options(
          headers: <String, dynamic>{
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: <String, String>{
          'name': userDetails['name']!,
          'email': userDetails['email']!,
          if (userDetails['phone']!.isNotEmpty) 'phone': userDetails['phone']!,
        },
      );

      if (response.statusCode == 200) {
        final String customerId = response.data['id'] as String;
        print("✅ Customer created: $customerId with name: ${userDetails['name']}");
        return customerId;
      }
    } catch (e) {
      print("❌ Error creating customer: $e");
    }

    return null;
  }

  /// Create SetupIntent for saving card
  Future<Map<String, dynamic>?> createSetupIntent(String customerId) async {
    try {
      final Response<dynamic> response = await dio.post(
        'https://api.stripe.com/v1/setup_intents',
        options: Options(
          headers: <String, dynamic>{
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: <String, String>{
          'customer': customerId,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print("❌ Error creating setup intent: $e");
    }

    return null;
  }

  /// Create Ephemeral Key for customer
  Future<Map<String, dynamic>?> createEphemeralKey(String customerId) async {
    try {
      final Response<dynamic> response = await dio.post(
        'https://api.stripe.com/v1/ephemeral_keys',
        options: Options(
          headers: <String, dynamic>{
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Stripe-Version': '2023-10-16',
          },
        ),
        data: <String, String>{
          'customer': customerId,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error creating ephemeral key: $e");
    }

    return null;
  }

  /// Check if card already exists in Firestore (only checking last4)
  Future<bool> _isCardAlreadyExists({required String last4}) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      // Check kar rahe hain ke same last4 wala card already exist karta hai
      final QuerySnapshot<Map<String, dynamic>> existingCards = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('card')
          .where('last4', isEqualTo: last4)
          .limit(1)
          .get();

      return existingCards.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking card existence: $e');
      return false;
    }
  }

  /// Save card using SetupIntent with cardholder name and store it in Firestore
  Future<void> saveCard(BuildContext context) async {
    try {
      // Get user details
      final Map<String, String> userDetails = await _getCurrentUserDetails();
      print('User details: ${userDetails['name']} - ${userDetails['email']}');

      // Create customer
      final String? customerId = await createCustomerIfNotExists();
      if (customerId == null) {
        _showErrorDialog(context, "Customer ID create nahi ho sakti. Dobara koshish karein.");
        return;
      }

      // Create setup intent
      final Map<String, dynamic>? setupIntent = await createSetupIntent(customerId);
      if (setupIntent == null) {
        _showErrorDialog(context, "Setup Intent create nahi ho saka. Dobara koshish karein.");
        return;
      }

      // Create ephemeral key
      final Map<String, dynamic>? ephemeralKey = await createEphemeralKey(customerId);
      if (ephemeralKey == null) {
        _showErrorDialog(context, "Ephemeral Key create nahi ho sakti. Dobara koshish karein.");
        return;
      }

      print('Initializing payment sheet with billing details...');

      // Initialize payment sheet with billing details
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: setupIntent['client_secret'],
          merchantDisplayName: 'PayFussion',
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKey['secret'],
          billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(
            name: CollectionMode.always,
            email: CollectionMode.always,
            phone: CollectionMode.always,
            address: AddressCollectionMode.full,
            attachDefaultsToPaymentMethod: true,
          ),
          billingDetails: BillingDetails(
            name: userDetails['name'],
            email: userDetails['email'],
            phone: userDetails['phone']!.isNotEmpty ? userDetails['phone'] : null,
            address: const Address(
              country: 'PK',
              city: null,
              line1: null,
              line2: null,
              postalCode: null,
              state: null,
            ),
          ),
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF0066FF),
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFF0066FF),
                  text: Colors.white,
                  border: Color(0xFF0066FF),
                ),
              ),
            ),
          ),
          googlePay: const PaymentSheetGooglePay(
            testEnv: true,
            currencyCode: "PKR",
            merchantCountryCode: "PK",
          ),
        ),
      );

      print('Presenting payment sheet...');
      await Stripe.instance.presentPaymentSheet();
      print('Payment sheet completed!');

      /// Fetch saved cards from Stripe
      final List<dynamic> cards = await listSavedCards(customerId);
      print('Found ${cards.length} saved cards');

      // Track karne ke liye ke koi card add hua ya nahi
      bool cardAdded = false;
      bool duplicateFound = false;

      // Save cards to Firebase with duplication check (only checking last4)
      for (final dynamic card in cards) {
        final Map<String, dynamic> cardDetails = card['card'] as Map<String, dynamic>;
        final String last4 = cardDetails['last4'] ?? '';

        // Check kar rahe hain ke card already exist karta hai (sirf last4 se)
        final bool exists = await _isCardAlreadyExists(last4: last4);

        if (exists) {
          print('⚠️ Card already exists with last4: $last4');
          duplicateFound = true;

          // Stripe se bhi card detach kar dein agar duplicate hai
          try {
            final String paymentMethodId = card['id'] as String;
            await dio.post(
              'https://api.stripe.com/v1/payment_methods/$paymentMethodId/detach',
              options: Options(
                headers: <String, dynamic>{
                  'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
                  'Content-Type': 'application/x-www-form-urlencoded',
                },
              ),
            );
            print('✅ Duplicate card detached from Stripe');
          } catch (e) {
            print('❌ Error detaching duplicate card: $e');
          }

          continue; // Skip this card
        }

        // Agar card exist nahi karta, to save kar dein
        await _saveCardToFirestore(
          cardData: card,
          customerId: customerId,
          cardholderName: userDetails['name']!,
          cardholderEmail: userDetails['email']!,
        );
        cardAdded = true;
      }

      // Use BLoC to reload cards
      context.read<CardBloc>().add(LoadCards());

      // User ko appropriate message dikhaye
      if (duplicateFound && !cardAdded) {
        _showErrorDialog(
          context,
          "This card already exists!\nYou cannot add the same card again.",
        );
      } else if (cardAdded) {
        _showSuccessDialog(context, "Card added successfully!");
      }

      print('Card save process completed!');
    } on StripeException catch (e) {
      print("Stripe Error: ${e.error.localizedMessage}");

      if (e.error.code == FailureCode.Canceled) {
        print('User canceled the payment sheet');
      } else if (e.error.code == FailureCode.Failed) {
        _showErrorDialog(context, "Card add karne mein masla: ${e.error.localizedMessage}");
      }

      context.read<CardBloc>().add(LoadCards());
    } catch (e) {
      print("Error in saveCard: $e");
      _showErrorDialog(context, "Card add nahi ho saka. Dobara koshish karein.");
      context.read<CardBloc>().add(LoadCards());
    }
  }

  /// Save card details to Firestore with cardholder name
  Future<void> _saveCardToFirestore({
    required dynamic cardData,
    required String customerId,
    required String cardholderName,
    required String cardholderEmail,
  }) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ No user logged in');
        return;
      }

      final String paymentMethodId = cardData['id'] as String;
      final Map<String, dynamic> card = cardData['card'] as Map<String, dynamic>;

      // Get billing details if available
      final Map<String, dynamic>? billingDetails = cardData['billing_details'] as Map<String, dynamic>?;

      // Prepare card data for Firestore
      final Map<String, dynamic> cardDataToSave = <String, dynamic>{
        'payment_method_id': paymentMethodId,
        'customer_id': customerId,
        'brand': card['brand'] ?? 'unknown',
        'last4': card['last4'] ?? '****',
        'exp_month': card['exp_month'] ?? 0,
        'exp_year': card['exp_year'] ?? 0,
        'country': card['country'] ?? '',
        'funding': card['funding'] ?? 'unknown',
        'cardholder_name': billingDetails?['name'] ?? cardholderName,
        'cardholder_email': billingDetails?['email'] ?? cardholderEmail,
        'cardholder_phone': billingDetails?['phone'] ?? '',
        'billing_address': billingDetails?['address'] != null
            ? <String, dynamic>{
          'city': billingDetails!['address']['city'] ?? '',
          'country': billingDetails['address']['country'] ?? '',
          'line1': billingDetails['address']['line1'] ?? '',
          'line2': billingDetails['address']['line2'] ?? '',
          'postal_code': billingDetails['address']['postal_code'] ?? '',
          'state': billingDetails['address']['state'] ?? '',
        }
            : <String, dynamic>{},
        'is_default': true,
        'create_date': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'created_by': currentUser.uid,
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('card')
          .add(cardDataToSave);

      print('✅ Card saved to Firestore: ${card['brand']} ending in ${card['last4']}');
    } catch (e) {
      print('❌ Error saving card to Firestore: $e');
    }
  }

  /// Show error dialog to user
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show success dialog to user
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// List saved payment methods (cards)
  Future<List<dynamic>> listSavedCards(String customerId) async {
    try {
      final Response<dynamic> response = await dio.get(
        'https://api.stripe.com/v1/payment_methods?customer=$customerId&type=card',
        options: Options(
          headers: <String, dynamic>{
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      }
    } catch (e) {
      print("❌ Error listing saved cards: $e");
    }

    return <dynamic>[];
  }

  /// Pay with saved card
  Future<bool> payWithSavedCard({
    required String paymentMethodId,
    required String customerId,
    required int amount,
  }) async {
    try {
      final Response<dynamic> response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        options: Options(
          headers: <String, dynamic>{
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: <String, String>{
          'amount': amount.toString(),
          'currency': 'pkr',
          'customer': customerId,
          'payment_method': paymentMethodId,
          'off_session': 'true',
          'confirm': 'true',
        },
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;

      if (data['status'] == 'succeeded') {
        print("✅ Payment succeeded!");
        return true;
      } else {
        print("❌ Payment failed: ${data['error'] ?? 'Unknown error'}");
        return false;
      }
    } catch (e) {
      print("❌ Error in payment: $e");
      return false;
    }
  }

  /// Get saved cards from Firestore for current user
  Future<List<Map<String, dynamic>>> getSavedCardsFromFirestore() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ No user logged in');
        return <Map<String, dynamic>>[];
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .collection("card")
          .orderBy("create_date", descending: true)
          .get();

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => <String, dynamic>{
        'id': doc.id,
        ...doc.data(),
      })
          .toList();
    } catch (e) {
      print("❌ Error getting saved cards: $e");
      return <Map<String, dynamic>>[];
    }
  }

  /// Delete card from both Stripe and Firestore
  Future<bool> deleteCard({
    required String paymentMethodId,
    required String firestoreDocId,
  }) async {
    try {
      // Delete from Stripe
      final Response<dynamic> response = await dio.post(
        'https://api.stripe.com/v1/payment_methods/$paymentMethodId/detach',
        options: Options(
          headers: <String, dynamic>{
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Delete from Firestore
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.uid)
              .collection("card")
              .doc(firestoreDocId)
              .delete();

          print("✅ Card deleted successfully");
          return true;
        }
      }

      return false;
    } catch (e) {
      print("❌ Error deleting card: $e");
      return false;
    }
  }
}