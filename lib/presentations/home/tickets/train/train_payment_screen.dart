import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/tax.dart';
import '../../../../data/models/card/card_model.dart';
import '../../../../data/models/tickets/train_model.dart';
import '../../../../logic/blocs/add_card/card_bloc.dart';
import '../../../../logic/blocs/add_card/card_event.dart';
import '../../../../logic/blocs/add_card/card_state.dart';
import '../../../../logic/blocs/tickets/train/train_bloc.dart';
import '../../../../logic/blocs/tickets/train/train_event.dart';
import '../../../../logic/blocs/tickets/train/train_state.dart';
import '../../../../services/payment_service.dart';

class TrainPaymentScreen extends StatefulWidget {
  final TrainModel train;
  const TrainPaymentScreen({super.key, required this.train});
  @override
  State<TrainPaymentScreen> createState() => _TrainPaymentScreenState();
}

class _TrainPaymentScreenState extends State<TrainPaymentScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _cardController;
  late AnimationController _buttonController;
  late List<AnimationController> _sectionControllers;

  final _formKey = GlobalKey<FormState>();
  final _controllers = <TextEditingController>[
    TextEditingController(), // name
    TextEditingController(), // email
    TextEditingController(), // phone
  ];

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _numberOfPassengers = 1;
  String _selectedClass = 'Economy';
  CardModel? _selectedCard;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    context.read<CardBloc>().add(LoadCards());
    _startAnimations();
  }

  void _initAnimations() {
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _sectionControllers = List.generate(5, (index) => AnimationController(
      duration: Duration(milliseconds: 600 + (index * 100)),
      vsync: this,
    ));
  }

  void _startAnimations() {
    _pageController.forward();
    for (int i = 0; i < _sectionControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _sectionControllers[i].forward();
      });
    }
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _cardController.forward();
        _buttonController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cardController.dispose();
    _buttonController.dispose();
    _sectionControllers.forEach((c) => c.dispose());
    _controllers.forEach((c) => c.dispose());
    super.dispose();
  }

  // Calculation getters
  double get _baseFare => widget.train.approxCostUSD * _numberOfPassengers;
  double get _classUpgradeAmount => _selectedClass == 'Economy' ? 0.0 : _baseFare * 0.5;
  double get _subtotal => _baseFare + _classUpgradeAmount;
  double get _ticketTax => _subtotal * (Taxes.ticketFeeTax / 100);
  double get _totalAmount => _subtotal + _ticketTax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocListener<BookingBloc, BookingState>(
        listener: _handleBookingState,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildAnimatedSection(0, _buildTripSummary()),
                _buildAnimatedSection(1, _buildPassengerDetails()),
                _buildAnimatedSection(2, _buildTravelOptions()),
                _buildAnimatedSection(3, _buildPaymentMethod()),
                _buildAnimatedSection(4, _buildFareBreakdown()),
                const SizedBox(height: 24),
                _buildAnimatedBookButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Hero(
        tag: 'payment-title',
        child: Text("Book Ticket"),
      ),
      iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return AnimatedBuilder(
      animation: _sectionControllers[index],
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _sectionControllers[index].value)),
          child: Opacity(
            opacity: _sectionControllers[index].value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBookButton() {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, _) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _buttonController.value),
          child: Opacity(
            opacity: _buttonController.value,
            child: _buildBookButton(),
          ),
        );
      },
    );
  }

  void _handleBookingState(BuildContext context, BookingState state) {
    if (state is BookingSuccess) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.green),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (state is BookingError) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildTripSummary() {
    return _buildCard(
      title: "Trip Summary",
      icon: Icons.train,
      children: [
        _buildInfoRow("Train", widget.train.name),
        _buildInfoRow("Route", widget.train.route),
        _buildInfoRow("Duration", "${widget.train.duration.inHours}h ${widget.train.duration.inMinutes % 60}m"),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text("Travel Date: "),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: TextButton(
                onPressed: _selectDate,
                child: Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  style: const TextStyle(color: MyTheme.secondaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPassengerDetails() {
    return _buildCard(
      title: "Passenger Details",
      icon: Icons.person,
      children: [
        _buildAnimatedTextField(_controllers[0], "Full Name", Icons.person, _validateName),
        const SizedBox(height: 16),
        _buildAnimatedTextField(_controllers[1], "Email", Icons.email, _validateEmail, TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildAnimatedTextField(_controllers[2], "Phone Number", Icons.phone, _validatePhone, TextInputType.phone),
      ],
    );
  }

  Widget _buildTravelOptions() {
    return _buildCard(
      title: "Travel Options",
      icon: Icons.settings,
      children: [
        Row(
          children: [
            Expanded(child: _buildPassengerCounter()),
            const SizedBox(width: 16),
            Expanded(child: _buildClassSelector()),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return _buildCard(
      title: "Payment Method",
      icon: Icons.payment,
      titleWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          AppButton(
            onTap: () => PaymentService().saveCard(context),
            height: 30,
            width: 100,
            color: MyTheme.secondaryColor,
            text: "Add Card",
          ),
        ],
      ),
      children: [_buildCardsSection()],
    );
  }

  Widget _buildFareBreakdown() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: _buildCard(
        title: "Fare Breakdown",
        icon: Icons.receipt,
        children: [
          _buildFareRow("Base Fare ($_numberOfPassengers passenger${_numberOfPassengers > 1 ? 's' : ''})", _baseFare),
          if (_selectedClass == 'Business')
            _buildFareRow("Business Class Upgrade (50%)", _classUpgradeAmount),
          _buildFareRow("Subtotal", _subtotal),
          _buildFareRow("Ticket Tax (${Taxes.ticketFeeTax}%)", _ticketTax),
          const Divider(),
          _buildFareRow("Total Amount", _totalAmount, isTotal: true),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? titleWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleWidget ?? Row(
              children: [
                Icon(icon, color: MyTheme.secondaryColor, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(color: Colors.grey.shade600)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      String? Function(String?) validator, [
        TextInputType? keyboardType,
      ]) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0, end: 1),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: AppTextormField(
              controller: controller,
              prefixIcon: Icon(icon,color: MyTheme.secondaryColor,),
              helpText: label,
              useGreenColor: true,
              validator: validator,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPassengerCounter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Passengers"),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCounterButton(Icons.remove, _numberOfPassengers > 1, () {
              setState(() => _numberOfPassengers--);
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$_numberOfPassengers',
                  key: ValueKey(_numberOfPassengers),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildCounterButton(Icons.add, _numberOfPassengers < 6, () {
              setState(() => _numberOfPassengers++);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton(IconData icon, bool enabled, VoidCallback onPressed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon,color: Colors.white,),
        style: IconButton.styleFrom(
          backgroundColor: enabled ? MyTheme.secondaryColor : Colors.grey.shade200,
        ),
      ),
    );
  }

  Widget _buildClassSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Travel Class"),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: DropdownButtonFormField<String>(
            value: _selectedClass,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: MyTheme.secondaryColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: MyTheme.secondaryColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: MyTheme.secondaryColor,
                ),
              ),
              focusColor: MyTheme.secondaryColor,
            ),
            items: ['Economy', 'Business'].map((cls) => DropdownMenuItem(value: cls, child: Text(cls))).toList(),
            onChanged: (value) => setState(() => _selectedClass = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildFareRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green.shade600 : null,
            ),
            child: Text("\$${amount.toStringAsFixed(2)}"),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: AppButton(
              onTap: state is BookingLoading ? null : _processBooking,
              text: 'Confirm Booking & Pay',
              color: MyTheme.secondaryColor,
            ),
          );
        },
      ),
    );
  }

  /// Card Selection (Compressed)
  Widget _buildCardsSection() {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _cardController.value)),
          child: Opacity(
            opacity: _cardController.value,
            child: BlocBuilder<CardBloc, CardState>(
              builder: (context, state) {
                if (state is CardLoading) return const Center(child: CircularProgressIndicator());
                if (state is CardLoaded) return _buildCardsList(state.cards);
                if (state is CardError) return _buildErrorCard(state.message);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardsList(List<CardModel> cards) {
    if (cards.isEmpty) {
      return Container(
        width: double.infinity,
        height: 60,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No cards available. Please add a card first.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    _selectedCard ??= cards.firstWhere((card) => card.isDefault, orElse: () => cards.first);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCardItem(_selectedCard!, true, () => _showCardSelection(cards)),
        const SizedBox(height: 8),
        const Text(
          'Tap to change card',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Error: $message',
            style: const TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          TextButton(
            onPressed: () => context.read<CardBloc>().add(LoadCards()),
            child: const Text('Retry', style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(CardModel card, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 24,
              child: Image.asset(
                card.brandIconPath,
                fit: BoxFit.contain,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 24,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.credit_card, size: 16),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.cardEnding,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Exp: ${card.formattedExpiry}${card.isDefault ? ' • Default' : ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: MyTheme.secondaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  /// Event Handlers
  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _showCardSelection(List<CardModel> cards) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: cards.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return _buildCardItem(
                    card,
                    _selectedCard?.id == card.id,
                        () {
                      setState(() => _selectedCard = card);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processBooking() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method'), backgroundColor: Colors.red),
      );
      return;
    }

    final booking = BookingModel(
      id: const Uuid().v4(),
      trainId: widget.train.id,
      trainName: widget.train.name,
      passengerName: _controllers[0].text,
      email: _controllers[1].text,
      phone: _controllers[2].text,
      travelDate: _selectedDate,
      numberOfPassengers: _numberOfPassengers,
      totalAmount: _totalAmount,
      baseFare: _baseFare,
      classUpgradeAmount: _classUpgradeAmount,
      taxAmount: _ticketTax,
      travelClass: _selectedClass,
      paymentStatus: 'completed',
      bookingDate: DateTime.now(),
    );

    context.read<BookingBloc>().add(CreateBooking(booking));
  }

  // Validators
  String? _validateName(String? value) => value?.isEmpty ?? true ? 'Please enter passenger name' : null;
  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter email address';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) return 'Please enter valid email';
    return null;
  }
  String? _validatePhone(String? value) => value?.isEmpty ?? true ? 'Please enter phone number' : null;
}