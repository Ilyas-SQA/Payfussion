class SubmitATicketState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? ticketId;

  SubmitATicketState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.ticketId,
  });

  SubmitATicketState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? ticketId,
  }) {
    return SubmitATicketState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      ticketId: ticketId ?? this.ticketId,
    );
  }
}
