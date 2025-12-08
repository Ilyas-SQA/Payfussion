import '../../../data/models/transaction_limit/transaction_limit_model.dart';

abstract class LimitState {}

class LimitInitial extends LimitState {}

class LimitLoading extends LimitState {}

class LimitLoaded extends LimitState {
  final TransactionLimitData limitData;
  final LimitOption? tempSelectedLimit;
  final List<LimitOption> availableLimits;

  LimitLoaded({
    required this.limitData,
    this.tempSelectedLimit,
    required this.availableLimits,
  });

  LimitLoaded copyWith({
    TransactionLimitData? limitData,
    LimitOption? tempSelectedLimit,
    List<LimitOption>? availableLimits,
    bool clearTempSelection = false,
  }) {
    return LimitLoaded(
      limitData: limitData ?? this.limitData,
      tempSelectedLimit: clearTempSelection ? null : (tempSelectedLimit ?? this.tempSelectedLimit),
      availableLimits: availableLimits ?? this.availableLimits,
    );
  }
}

class LimitError extends LimitState {
  final String message;
  LimitError(this.message);
}

class LimitUpdating extends LimitState {}
