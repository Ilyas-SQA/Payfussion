import 'package:flutter/material.dart';
import 'package:payfussion/presentations/home/receive_money/receive_money_payment_form.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/image_url.dart';
import '../../../data/models/payment/contact_modal.dart';
import '../../../data/models/payment/payment_account_modal.dart';
import '../../../services/biometric_service.dart';
import '../../payment_strings.dart';
import '../../widgets/background_theme.dart';

class ReceiveMoneyPaymentProvider extends ChangeNotifier {
  double _amount = 0.0;
  String? _amountError;
  String _note = '';
  bool _isProcessing = false;
  bool _isSuccess = false;
  String? _errorMessage;
  int _expiryDays = 7;
  List<Contact> _contacts = <Contact>[];
  Contact? _selectedContact;
  bool _isLoadingContacts = false;
  final BiometricService _biometricService = BiometricService();

  List<PaymentAccount> _accounts = <PaymentAccount>[];
  PaymentAccount? _selectedAccount;
  String? _paymentLink;
  String? _qrCodeData;

  // Getters
  double get amount => _amount;

  String? get amountError => _amountError;

  String get note => _note;

  bool get isProcessing => _isProcessing;

  bool get isSuccess => _isSuccess;

  String? get errorMessage => _errorMessage;

  List<PaymentAccount> get accounts => _accounts;

  PaymentAccount? get selectedAccount => _selectedAccount;

  int get expiryDays => _expiryDays;

  String? get paymentLink => _paymentLink;

  String? get qrCodeData => _qrCodeData;

  List<Contact> get contacts => _contacts;

  Contact? get selectedContact => _selectedContact;

  bool get isLoadingContacts => _isLoadingContacts;

  ReceiveMoneyPaymentProvider() {
    _loadAccounts();
    _loadContacts();
  }

  // Load available payment accounts
  Future<void> _loadAccounts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    _accounts = <PaymentAccount>[
      const PaymentAccount(
        id: 'acc1',
        name: 'Main Account',
        accountNumber: '****6789',
        cardType: 'Visa',
        balance: 2450.75,
        imageUrl: TImageUrl.iconVisa,
        isDefault: true,
      ),
      const PaymentAccount(
        id: 'acc2',
        name: 'Savings',
        accountNumber: '****1234',
        cardType: 'Mastercard',
        balance: 5678.50,
        imageUrl: TImageUrl.iconMasterCard,
      ),
      const PaymentAccount(
        id: 'acc3',
        name: 'Business Account',
        accountNumber: '****5432',
        cardType: 'Amex',
        balance: 10450.25,
        imageUrl: 'assets/images/amex_card.png',
      ),
    ];

    // Set default account
    _selectedAccount = _accounts.firstWhere(
      (PaymentAccount account) => account.isDefault,
      orElse: () => _accounts.first,
    );

    notifyListeners();
  }

  Future<void> _loadContacts() async {
    _isLoadingContacts = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));

      // Mock contact data - in a real app, this would come from a contacts API
      _contacts = <Contact>[
        const Contact(
          id: 'contact1',
          name: 'Alice Wonderland',
          phoneNumber: '+1 555-123-4567',
          email: 'alice@example.com',
          imageUrl: 'https://picsum.photos/seed/alice/200',
        ),
        const Contact(
          id: 'contact2',
          name: 'Bob Builder',
          phoneNumber: '+1 555-987-6543',
          email: 'bob@example.com',
          imageUrl: 'https://picsum.photos/seed/bob/200',
        ),
        const Contact(
          id: 'contact3',
          name: 'Carol Smith',
          phoneNumber: '+1 555-444-3333',
          email: 'carol@example.com',
        ),
        const Contact(
          id: 'contact4',
          name: 'David Jones',
          phoneNumber: '+1 555-222-1111',
          email: 'david@example.com',
          imageUrl: 'https://picsum.photos/seed/david/200',
        ),
      ];

      _isLoadingContacts = false;
      notifyListeners();
    } catch (e) {
      _isLoadingContacts = false;
      _errorMessage = 'Failed to load contacts';
      notifyListeners();
    }
  }

  // Select a contact
  void selectContact(Contact contact) {
    _selectedContact = contact;
    notifyListeners();
  }

  // Set amount with validation
  void setAmount(String value) {
    // Remove any non-numeric characters except decimal point
    final String sanitized = value.replaceAll(RegExp(r'[^\d.]'), '');

    if (sanitized.isEmpty) {
      _amount = 0.0;
      _amountError = null;
    } else {
      try {
        _amount = double.parse(sanitized);
        _validateAmount();
      } catch (e) {
        _amountError = ReceiveMoneyPaymentStrings.invalidAmount;
      }
    }

    notifyListeners();
  }

  // Set note
  void setNote(String value) {
    _note = value;
    notifyListeners();
  }

  // Select an account
  void selectAccount(PaymentAccount account) {
    _selectedAccount = account;
    notifyListeners();
  }

  // Set expiry days
  void setExpiryDays(int days) {
    _expiryDays = days;
    notifyListeners();
  }

  // Validate the entered amount
  void _validateAmount() {
    if (_amount <= 0) {
      _amountError = ReceiveMoneyPaymentStrings.invalidAmount;
    } else if (_amount < 1.0) {
      _amountError = ReceiveMoneyPaymentStrings.amountTooSmall;
    } else if (_amount > 50000) {
      // Example limit
      _amountError = ReceiveMoneyPaymentStrings.amountTooLarge;
    } else {
      _amountError = null;
    }
  }

  // Format amount as currency
  String getFormattedAmount() {
    if (_amount == 0) return '';

    return '\$${_amount.toStringAsFixed(2)}';
  }

  // Process the payment request
  Future<bool> createPaymentRequest() async {
    _validateAmount();

    if (_amountError != null ||
        _selectedAccount == null ||
        _selectedContact == null) {
      // Add validation error if no recipient is selected
      if (_selectedContact == null) {
        _errorMessage = 'Please select a recipient';
      }
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if biometrics are available and enrolled
      final bool isBiometricAvailable = await _biometricService
          .isBiometricAvailable();
      final bool hasBiometrics = await _biometricService.hasBiometricsEnrolled();

      if (isBiometricAvailable && hasBiometrics) {
        // Request biometric authentication
        final Map<String, dynamic> authResult = await _biometricService.authenticate(
          reason:
              'Authenticate to request \$${_amount.toStringAsFixed(2)} from ${_selectedContact!.name}',
        );

        if (!authResult['success']) {
          _isProcessing = false;
          _errorMessage = 'Authentication failed: ${authResult['error']}';
          notifyListeners();
          return false;
        }
      }

      // Simulate network delay for payment request creation
      await Future.delayed(const Duration(milliseconds: 1500));

      // In a real app, make API call to create payment request here
      _paymentLink =
          'https://pay.example.com/request/${DateTime.now().millisecondsSinceEpoch}';
      _qrCodeData =
          'PAY:$_paymentLink:${_amount.toStringAsFixed(2)}:${_note.isEmpty ? 'Payment Request' : _note}';

      _isProcessing = false;
      _isSuccess = true;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      _errorMessage = 'Request creation failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Reset form state
  void reset() {
    _amount = 0.0;
    _amountError = null;
    _note = '';
    _isProcessing = false;
    _isSuccess = false;
    _errorMessage = null;
    _paymentLink = null;
    _qrCodeData = null;
    notifyListeners();
  }
}

class ReceiveMoneyPaymentScreen extends StatefulWidget {
  const ReceiveMoneyPaymentScreen({super.key});

  @override
  State<ReceiveMoneyPaymentScreen> createState() => _ReceiveMoneyPaymentScreenState();
}

class _ReceiveMoneyPaymentScreenState extends State<ReceiveMoneyPaymentScreen> with TickerProviderStateMixin{
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReceiveMoneyPaymentProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            ReceiveMoneyPaymentStrings.paymentScreen,
            semanticsLabel: 'Request Payment Screen',
          ),
        ),
        body: Stack(
          children: <Widget>[
            AnimatedBackground(
              animationController: _backgroundAnimationController,
            ),
            const ReceiveMoneyPaymentForm(),
          ],
        ),
      ),
    );
  }
}
