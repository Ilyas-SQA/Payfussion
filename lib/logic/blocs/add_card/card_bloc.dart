import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/card/card_model.dart';
import '../../../data/repositories/card/card_repository.dart';
import '../../../services/payment_service.dart';
import '../../../services/service_locator.dart';
import 'card_event.dart';
import 'card_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final PaymentService paymentService = getIt<PaymentService>();
  final CardRepository repository = CardRepository();

  CardBloc() : super(AddCardInitial()) {
    on<LoadCards>(_getAllCard);
    on<SetDefaultCard>(_setDefaultCard);
    on<AddCardWithDuplicateCheck>(_addCardWithDuplicateCheck); // NEW EVENT HANDLER
  }

  Future<void> _getAllCard(LoadCards event, Emitter<CardState> emit) async {
    try {
      await emit.forEach<List<CardModel>>(
        repository.getUserCards(),
        onData: (cards) => CardLoaded(cards),
        onError: (_, __) => const CardError("Failed to load cards"),
      );
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> _setDefaultCard(SetDefaultCard event, Emitter<CardState> emit) async {
    final currentState = state;
    if (currentState is CardLoaded) {
      // Update local cards list
      List<CardModel> updatedCards = currentState.cards.map((card) {
        if (card.id == event.cardId) {
          return card.copyWith(isDefault: event.isDefault);
        } else if (event.isDefault) {
          return card.copyWith(isDefault: false);
        }
        return card;
      }).toList();

      emit(CardLoaded(updatedCards));

      // Update Firebase
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final batch = FirebaseFirestore.instance.batch();

      // Set the selected card as default
      batch.update(
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('card')
            .doc(event.cardId),
        {'is_default': event.isDefault},
      );

      // Unset other cards if needed
      if (event.isDefault) {
        for (var card in updatedCards) {
          if (card.id != event.cardId && card.isDefault == false) continue;
          if (card.id != event.cardId) {
            batch.update(
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('card')
                  .doc(card.id),
              {'is_default': false},
            );
          }
        }
      }

      await batch.commit();
    }
  }

  // NEW METHOD - Duplicate check handler
  Future<void> _addCardWithDuplicateCheck(
      AddCardWithDuplicateCheck event,
      Emitter<CardState> emit,
      ) async {
    try {
      emit(AddCardLoading());

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final cardsCollection = FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("card");

      // Check for existing cards
      final existingCardsSnapshot = await cardsCollection
          .where('stripe_customer_id', isEqualTo: event.customerId)
          .get();

      // Check if card already exists
      final cardToAdd = event.cardData;
      final newCardIdentifier = '${cardToAdd['card']['brand']}_${cardToAdd['card']['last4']}';

      bool isDuplicate = false;
      for (final doc in existingCardsSnapshot.docs) {
        final data = doc.data();
        final existingIdentifier = '${data['brand']}_${data['last4']}';

        if (existingIdentifier == newCardIdentifier) {
          isDuplicate = true;
          break;
        }
      }

      if (isDuplicate) {
        emit(const CardDuplicateDetected('آپ پہلے سے موجود کارڈ دوبارہ شامل نہیں کر سکتے'));
        return;
      }

      // Add new card if not duplicate
      await cardsCollection.add({
        'stripe_customer_id': event.customerId,
        'payment_method_id': cardToAdd['id'].toString(),
        'brand': cardToAdd['card']['brand'].toString(),
        'last4': cardToAdd['card']['last4'].toString(),
        'exp_month': cardToAdd['card']['exp_month'].toString(),
        'exp_year': cardToAdd['card']['exp_year'].toString(),
        "create_date": DateTime.now(),
        "is_default": existingCardsSnapshot.docs.isEmpty,
      });

      emit(AddCardSuccess(paymentMethodId: cardToAdd['id'].toString()));

      // Reload cards to update the UI
      add(LoadCards());

    } catch (e) {
      emit(AddCardFailure("Error adding card: ${e.toString()}"));
    }
  }
}