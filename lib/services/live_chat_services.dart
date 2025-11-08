import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart' hide Message;

import '../data/models/messages/message_model.dart';

class LiveChatServices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DialogFlowtter? dialogFlowtter;
  bool _isInitialized = false;

  Future<void> initializeDialogflow() async {
    try {
      if (_isInitialized && dialogFlowtter != null) {
        return; // Already initialized
      }

      print('Initializing DialogFlowtter...');

      // Make sure the JSON file path is correct
      dialogFlowtter = await DialogFlowtter.fromFile(
        path: 'assets/pay-fussion-igqa.json',
      );

      _isInitialized = true;
      print('DialogFlowtter initialized successfully');
    } catch (e) {
      print('Error initializing DialogFlowtter: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<String> sendMessage(String message) async {
    try {
      // Validate input
      if (message.trim().isEmpty) {
        return "Please enter a message.";
      }

      print('Sending message to DialogFlow: $message');

      // Ensure DialogFlowtter is initialized
      if (!_isInitialized || dialogFlowtter == null) {
        print('DialogFlowtter not initialized, initializing now...');
        await initializeDialogflow();
      }

      // Double check initialization
      if (dialogFlowtter == null) {
        throw Exception('Failed to initialize DialogFlowtter');
      }

      // Send message to DialogFlow
      final DetectIntentResponse response = await dialogFlowtter!.detectIntent(
        queryInput: QueryInput(
          text: TextInput(
              text: message.trim(),
              languageCode: 'en'
          ),
        ),
      );

      print('DialogFlow response received: ${response.toString()}');

      // Extract response text with comprehensive null safety
      String? responseText;

      // Check multiple possible response formats
      if (response.message != null) {
        if (response.message!.text != null &&
            response.message!.text!.text != null &&
            response.message!.text!.text!.isNotEmpty) {
          responseText = response.message!.text!.text!.first;
        }
      }

      // Check alternative response formats for dialog_flowtter package
      if (responseText == null || responseText.trim().isEmpty) {
        // Try to get text from alternative message formats
        if (response.text != null && response.text!.isNotEmpty) {
          responseText = response.text;
        }
      }

      // Check if there are any alternative message responses
      if (responseText == null || responseText.trim().isEmpty) {
        // Some versions might have different response structure
        print('Response structure: ${response.toString()}');
        print('Available properties in response: ${response.runtimeType}');
      }

      // Final validation and fallback
      if (responseText == null || responseText.trim().isEmpty) {
        print('Warning: No valid response text found in DialogFlow response');
        return "I understand your message, but I'm not sure how to respond right now. Please try rephrasing your question.";
      }

      print('Final response text: $responseText');
      return responseText.trim();

    } catch (e) {
      print('Error in sendMessage: $e');

      // Return user-friendly error message instead of throwing
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        return "I'm having trouble connecting right now. Please check your internet connection and try again.";
      } else if (e.toString().contains('permission') || e.toString().contains('unauthorized')) {
        return "There's a configuration issue with the chat service. Please contact support.";
      } else {
        return "I'm experiencing technical difficulties. Please try again in a moment.";
      }
    }
  }

  void dispose() {
    try {
      dialogFlowtter?.dispose();
      dialogFlowtter = null;
      _isInitialized = false;
      print('LiveChatServices disposed');
    } catch (e) {
      print('Error disposing LiveChatServices: $e');
    }
  }

  // Save message to Firestore with better error handling
  static Future<void> saveMessage({
    required String userId,
    required String text,
    required String sender,
  }) async {
    try {
      // Validate inputs
      if (userId.trim().isEmpty) {
        throw ArgumentError('userId cannot be empty');
      }
      if (text.trim().isEmpty) {
        throw ArgumentError('text cannot be empty');
      }
      if (sender.trim().isEmpty) {
        throw ArgumentError('sender cannot be empty');
      }

      await _firestore
          .collection('users')
          .doc(userId.trim())
          .collection('chatbots')
          .add(<String, dynamic>{
        'text': text.trim(),
        'sender': sender.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId.trim(),
      });

      print('Message saved to Firestore successfully');
    } catch (e) {
      print('Error saving message to Firestore: $e');
      // Don't rethrow - just log the error to prevent app crashes
      // rethrow;
    }
  }

  // Load messages from Firestore with null safety
  static Stream<List<Message>> getMessagesStream(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.value(<Message>[]);
    }

    return _firestore
        .collection('users')
        .doc(userId.trim())
        .collection('chatbots')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      try {
        return snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          try {
            return Message.fromSnapshot(doc);
          } catch (e) {
            print('Error parsing message document ${doc.id}: $e');
            return null;
          }
        })
            .where((Message? message) => message != null)
            .cast<Message>()
            .toList();
      } catch (e) {
        print('Error processing messages stream: $e');
        return <Message>[];
      }
    });
  }

  // Load initial messages with better error handling
  static Future<List<Message>> getInitialMessages(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        print('Warning: Empty userId provided to getInitialMessages');
        return <Message>[];
      }

      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .doc(userId.trim())
          .collection('chatbots')
          .orderBy('timestamp', descending: false)
          .get();

      final List<Message> messages = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        try {
          return Message.fromSnapshot(doc);
        } catch (e) {
          print('Error parsing message document ${doc.id}: $e');
          return null;
        }
      })
          .where((Message? message) => message != null)
          .cast<Message>()
          .toList();

      print('Loaded ${messages.length} messages from Firestore');
      return messages;
    } catch (e) {
      print('Error loading messages from Firestore: $e');
      return <Message>[];
    }
  }
}