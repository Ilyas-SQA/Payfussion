import '../../../data/models/transaction_limit/transaction_limit_model.dart';

abstract class LimitEvent {}

class LoadLimitEvent extends LimitEvent {
  final String userId;
  LoadLimitEvent(this.userId);
}

class UpdateLimitEvent extends LimitEvent {
  final String userId;
  final LimitOption selectedLimit;

  UpdateLimitEvent({
    required this.userId,
    required this.selectedLimit,
  });
}

class SelectTempLimitEvent extends LimitEvent {
  final LimitOption limit;
  SelectTempLimitEvent(this.limit);
}

class LoadAvailableLimitsEvent extends LimitEvent {
  final String userId;
  LoadAvailableLimitsEvent(this.userId);
}
