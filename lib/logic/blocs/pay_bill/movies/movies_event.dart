import 'package:equatable/equatable.dart';

abstract class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Set subscription data
class SetSubscriptionData extends MoviesEvent {
  final String serviceName;
  final String category;
  final String email;
  final String planName;
  final double planPrice;
  final String planDuration;
  final String planDescription;
  final bool autoRenew;

  const SetSubscriptionData({
    required this.serviceName,
    required this.category,
    required this.email,
    required this.planName,
    required this.planPrice,
    required this.planDuration,
    required this.planDescription,
    required this.autoRenew,
  });

  @override
  List<Object?> get props => <Object?>[
    serviceName,
    category,
    email,
    planName,
    planPrice,
    planDuration,
    planDescription,
    autoRenew,
  ];
}

// Set selected card
class SetSelectedCardForMovies extends MoviesEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCardForMovies({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => <Object>[cardId, cardHolderName, cardEnding];
}

// Process subscription payment
class ProcessSubscriptionPayment extends MoviesEvent {
  const ProcessSubscriptionPayment();
}

// Reset subscription state
class ResetSubscription extends MoviesEvent {
  const ResetSubscription();
}