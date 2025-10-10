import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/live_chat_services.dart';
import 'live_chat_event.dart';
import 'live_chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final LiveChatServices _dialogflowService;
  final String userId;

  ChatBloc({
    LiveChatServices? dialogflowService,
    required this.userId,
  }) : _dialogflowService = dialogflowService ?? LiveChatServices(),
        super(ChatInitial()) {
    on<LoadInitialMessages>(_onLoadInitialMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadInitialMessages(
      LoadInitialMessages event,
      Emitter<ChatState> emit,
      ) async {
    emit(ChatLoading());

    try {
      // Ensure DialogFlow is initialized
      await _dialogflowService.initializeDialogflow();

      // Load messages from Firestore
      final firestoreMessages = await LiveChatServices.getInitialMessages(userId);

      List<Map<String, dynamic>> messages = [];

      if (firestoreMessages.isEmpty) {
        // Add initial welcome message if no messages exist
        const welcomeMessage = 'Hello! How can we assist you today?';

        // Save welcome message to Firestore
        await LiveChatServices.saveMessage(
          userId: userId,
          text: welcomeMessage,
          sender: 'support',
        );

        messages.add({
          'sender': 'support',
          'text': welcomeMessage,
          'timestamp': DateTime.now(),
        });
      } else {
        /// Convert Firestore messages to the format used by UI with null safety
        messages = firestoreMessages.map((message) {
          /// Add null safety checks here
          return {
            'sender': message.sender,
            'text': message.text,
            'timestamp': message.timestamp,
          };
        }).toList();
      }

      emit(ChatLoaded(messages: messages));
      print('Messages loaded successfully from Firestore');

    } catch (e) {
      print('Error loading messages: $e');
      emit(ChatError('Failed to initialize chat: ${e.toString()}'));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event,
      Emitter<ChatState> emit,
      ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;

    try {
      /// Validate input message
      if (event.message.trim().isEmpty) {
        print('Empty message received, ignoring');
        return;
      }

      /// Save user message to Firestore first
      await LiveChatServices.saveMessage(
        userId: userId,
        text: event.message,
        sender: 'user',
      );

      /// Add user message to UI
      final updatedMessages = List<Map<String, dynamic>>.from(currentState.messages)
        ..add({
          'sender': 'user',
          'text': event.message,
          'timestamp': DateTime.now(),
        });

      // Show typing indicator
      emit(currentState.copyWith(
        messages: updatedMessages,
        isTyping: true,
      ));

      /// Get response from Dialogflow with null safety
      String? dialogflowResponse;
      try {
        dialogflowResponse = await _dialogflowService.sendMessage(event.message);
        print('DialogFlow response received: $dialogflowResponse');
      } catch (dialogflowError) {
        print('DialogFlow error: $dialogflowError');
        dialogflowResponse = null;
      }

      // Ensure we have a valid response
      final responseText = dialogflowResponse?.trim().isNotEmpty == true
          ? dialogflowResponse!
          : 'I apologize, but I\'m having trouble processing your request right now. Please try again.';

      // Save bot response to Firestore
      await LiveChatServices.saveMessage(
        userId: userId,
        text: responseText,
        sender: 'support',
      );

      // Add bot response to UI
      final finalMessages = List<Map<String, dynamic>>.from(updatedMessages)
        ..add({
          'sender': 'support',
          'text': responseText,
          'timestamp': DateTime.now(),
        });

      emit(ChatLoaded(
        messages: finalMessages,
        isTyping: false,
      ));

      print('Messages saved to Firestore successfully');

    } catch (e) {
      print('Error sending message: $e');

      // Get current messages safely
      List<Map<String, dynamic>> currentMessages = [];
      if (state is ChatLoaded) {
        currentMessages = List<Map<String, dynamic>>.from((state as ChatLoaded).messages);
      }

      // Add user message if it was not added due to error
      bool userMessageExists = currentMessages.any((msg) =>
      msg['text'] == event.message && msg['sender'] == 'user');

      if (!userMessageExists) {
        currentMessages.add({
          'sender': 'user',
          'text': event.message,
          'timestamp': DateTime.now(),
        });
      }

      // Add error message (but don't save error messages to Firestore)
      final errorMessages = List<Map<String, dynamic>>.from(currentMessages)
        ..add({
          'sender': 'support',
          'text': 'Sorry, there was an error processing your request. Please try again.',
          'timestamp': DateTime.now(),
        });

      emit(ChatLoaded(
        messages: errorMessages,
        isTyping: false,
      ));
    }
  }
}