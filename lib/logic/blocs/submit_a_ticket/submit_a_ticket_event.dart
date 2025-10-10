abstract class SubmitATicketEvent {}

class SubmitTicketEvent extends SubmitATicketEvent {
  final String title;
  final String description;

  SubmitTicketEvent({
    required this.title,
    required this.description,
  });
}

class ResetStateEvent extends SubmitATicketEvent {}