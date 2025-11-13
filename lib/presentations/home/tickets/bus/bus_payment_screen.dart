import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nested/nested.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';
import 'package:payfussion/services/payment_service.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/constants/tax.dart';
import '../../../../data/models/card/card_model.dart';
import '../../../../data/models/notification/notification_model.dart';
import '../../../../data/models/tickets/bus_model.dart';
import '../../../../logic/blocs/add_card/card_bloc.dart';
import '../../../../logic/blocs/add_card/card_event.dart';
import '../../../../logic/blocs/add_card/card_state.dart';
import '../../../../logic/blocs/notification/notification_bloc.dart';
import '../../../../logic/blocs/notification/notification_event.dart';
import '../../../../logic/blocs/notification/notification_state.dart';
import '../../../../logic/blocs/tickets/bus/bus_bloc.dart';
import '../../../../logic/blocs/tickets/bus/bus_event.dart';
import '../../../../logic/blocs/tickets/bus/bus_state.dart';
import '../../../widgets/background_theme.dart';
import '../../../widgets/custom_button.dart';


class BusPaymentScreen extends StatefulWidget {
  final BusModel bus;

  const BusPaymentScreen({super.key, required this.bus});

  @override
  State<BusPaymentScreen> createState() => _BusPaymentScreenState();
}

class _BusPaymentScreenState extends State<BusPaymentScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late AnimationController _backgroundAnimationController;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _numberOfPassengers = 1;
  String _selectedSeatType = 'Standard';
  CardModel? _selectedCard;

  @override
  void initState() {
    super.initState();
    context.read<CardBloc>().add(LoadCards());
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  double get _baseTicketPrice {
    return widget.bus.approxCostUSD * _numberOfPassengers;
  }

  double get _seatUpgradeAmount {
    if (_selectedSeatType == 'Standard') return 0.0;
    return widget.bus.approxCostUSD * _numberOfPassengers * 0.3; // 30% upgrade for Premium
  }

  double get _baseFare {
    return _baseTicketPrice + _seatUpgradeAmount;
  }

  double get _ticketTax {
    return _baseFare * (Taxes.ticketFeeTax / 100);
  }

  double get _totalAmount {
    return _baseFare + _ticketTax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Bus Ticket"),
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          MultiBlocListener(
            listeners: <SingleChildWidget>[
              BlocListener<BusBookingBloc, BusBookingState>(
                listener: (BuildContext context, BusBookingState state) {
                  if (state is BusBookingSuccess) {
                    // Add notification when booking is successful
                    _addTicketNotification(
                      success: true,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).popUntil((Route route) => route.isFirst);
                  } else if (state is BusBookingError) {
                    // Add notification when booking fails
                    _addTicketNotification(
                      success: false,
                      errorMessage: state.message,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              BlocListener<NotificationBloc, NotificationState>(
                listener: (BuildContext context, NotificationState state) {
                  if (state is NotificationError) {
                    // Handle notification error silently or log it
                    print('Notification error: ${state.message}');
                  }
                },
              ),
            ],
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildTripSummary(),
                    const SizedBox(height: 16),
                    _buildPassengerDetails(),
                    const SizedBox(height: 16),
                    _buildTravelOptions(),
                    const SizedBox(height: 16),
                    _buildPaymentMethod(),
                    const SizedBox(height: 16),
                    _buildFareBreakdown(),
                    const SizedBox(height: 24),
                    _buildBookButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to create ticket notifications
  void _addTicketNotification({
    required bool success,
    String? errorMessage,
  }) {
    final NotificationModel notification = NotificationModel.createTicketNotification(
      companyName: widget.bus.companyName,
      route: widget.bus.route,
      travelDate: _selectedDate,
      passengerName: _nameController.text,
      numberOfPassengers: _numberOfPassengers,
      totalAmount: _totalAmount,
      seatType: _selectedSeatType,
      status: success ? 'success' : 'failed',
      errorMessage: errorMessage,
    );

    context.read<NotificationBloc>().add(
      AddNotification(
        title: notification.title,
        message: notification.message,
        type: notification.type,
        data: notification.data,
      ),
    );
  }

  Widget _buildTripSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: <BoxShadow>[
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
          children: <Widget>[
            Text(
              "Trip Summary",
              style: Font.montserratFont(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text("Company: ${widget.bus.companyName}"),
            Text("Route: ${widget.bus.route}"),
            Text("Bus Type: ${widget.bus.busType}"),
            Text("Duration: ${widget.bus.duration.inHours}h ${widget.bus.duration.inMinutes % 60}m"),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const Text("Travel Date: "),
                TextButton(
                  onPressed: () async {
                    final DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: Text(
                    "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                    style: Font.montserratFont(color: Colors.orange.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: <BoxShadow>[
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
          children: <Widget>[
             Text(
              "Passenger Details",
              style: Font.montserratFont(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _nameController,
              helpText: "Full Name",
              prefixIcon: const Icon(Icons.person,color: MyTheme.secondaryColor,),
              useGreenColor: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter passenger name';
                }
                return null;
              }, isPasswordField: false,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _emailController,
              helpText: "Enter email address",
              prefixIcon: const Icon(Icons.email,color: MyTheme.secondaryColor,),
              isPasswordField: false,
              useGreenColor: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _phoneController,
              helpText: "Phone Number",
              prefixIcon: const Icon(Icons.phone,color: MyTheme.secondaryColor,),
              isPasswordField: false,
              useGreenColor: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: <BoxShadow>[
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
          children: <Widget>[
            Text(
              "Travel Options",
              style: Font.montserratFont(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text("Number of Passengers"),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: _numberOfPassengers > 1
                                ? () {
                              setState(() {
                                _numberOfPassengers--;
                              });
                            }
                                : null,
                            icon: const Icon(Icons.remove_circle_outline,color: MyTheme.secondaryColor,),
                          ),
                          Text(
                            '$_numberOfPassengers',
                            style: Font.montserratFont(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: _numberOfPassengers < 6
                                ? () {
                              setState(() {
                                _numberOfPassengers++;
                              });
                            }
                                : null,
                            icon: const Icon(Icons.add_circle_outline,color: MyTheme.secondaryColor,),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text("Seat Type"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSeatType,
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
                        items: <String>['Standard', 'Premium'].map((String type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedSeatType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: <BoxShadow>[
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
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10,
              children: <Widget>[
                Text(
                  "Payment Method",
                  style: Font.montserratFont(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: CustomButton(
                    height: 35.h,
                    width: 110,
                    backgroundColor: MyTheme.secondaryColor,
                    onPressed: () {
                      PaymentService().saveCard(context);
                    },
                    text: "Add Card",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCardsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFareBreakdown() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: <BoxShadow>[
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
          children: <Widget>[
            Text(
              "Fare Breakdown",
              style: Font.montserratFont(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Base Fare ($_numberOfPassengers passenger${_numberOfPassengers > 1 ? 's' : ''})"),
                Text("\$${(widget.bus.approxCostUSD * _numberOfPassengers).toStringAsFixed(2)}"),
              ],
            ),
            if (_selectedSeatType == 'Premium') ...<Widget>[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Premium Seat Upgrade (30%)"),
                  Text("\$${(widget.bus.approxCostUSD * _numberOfPassengers * 0.3).toStringAsFixed(2)}"),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text("Subtotal"),
                Text("\$${_baseFare.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text("Ticket Tax (${Taxes.ticketFeeTax}%)"),
                Text("\$${_ticketTax.toStringAsFixed(2)}"),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Total Amount",
                  style: Font.montserratFont(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\$${_totalAmount.toStringAsFixed(2)}",
                  style: Font.montserratFont(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<BusBookingBloc, BusBookingState>(
        builder: (BuildContext context, BusBookingState state) {
          return AppButton(
            text: "${state is BusBookingLoading ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ) : "Confirm Booking & Pay"}",
            color: MyTheme.secondaryColor,
            onTap: state is BusBookingLoading ? null : _processBooking,
          );
        },
      ),
    );
  }

  void _processBooking() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCard == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a payment method'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final BusBookingModel booking = BusBookingModel(
        id: const Uuid().v4(),
        busId: widget.bus.id,
        companyName: widget.bus.companyName,
        passengerName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        travelDate: _selectedDate,
        numberOfPassengers: _numberOfPassengers,
        totalAmount: _totalAmount,
        baseTicketPrice: _baseTicketPrice,
        seatUpgradeAmount: _seatUpgradeAmount,
        taxAmount: _ticketTax,
        paymentStatus: 'completed',
        bookingDate: DateTime.now(),
        seatType: _selectedSeatType,
      );

      context.read<BusBookingBloc>().add(CreateBusBooking(booking));
    }
  }

  Widget _buildCardsSection() {
    return BlocBuilder<CardBloc, CardState>(
      builder: (BuildContext context, CardState state) {
        if (state is CardLoading) {
          return Container(
            height: 60,
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is CardLoaded) {
          if (state.cards.isEmpty) {
            return Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'No cards available. Please add a card first.',
                  textAlign: TextAlign.center,
                  style: Font.montserratFont(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }

          if (_selectedCard == null) {
            _selectedCard = state.cards.firstWhere(
                  (CardModel card) => card.isDefault,
              orElse: () => state.cards.first,
            );
          }

          return Column(
            children: <Widget>[
              _buildAccountItem(
                context: context,
                card: _selectedCard!,
                isSelected: true,
                onTap: () {
                  _showCardSelectionBottomSheet(context, state.cards);
                },
              ),
              if (_selectedCard != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'Tap to change card',
                  style: Font.montserratFont(
                    fontSize: 10,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          );
        } else if (state is CardError) {
          return Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Error loading cards',
                    style: Font.montserratFont(color: Colors.red, fontSize: 12),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<CardBloc>().add(LoadCards());
                    },
                    child: Text('Retry', style: Font.montserratFont(fontSize: 10)),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAccountItem({required BuildContext context, required CardModel card, required bool isSelected, required VoidCallback onTap,}) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Image.asset(
              card.brandIconPath,
              height: 24.h,
              width: 32.w,
              color: isDark ? Colors.white : Colors.black,
            ),
            16.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    card.cardholderName,
                    style: Font.montserratFont(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    card.cardEnding,
                    style: Font.montserratFont(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  4.verticalSpace,
                  Text(
                    'Exp: ${card.formattedExpiry}${card.isDefault ? ' • Default' : ''}',
                    style: Font.montserratFont(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20.sp,
              ),
            8.horizontalSpace,
            Icon(
              CupertinoIcons.chevron_down,
              size: 16.sp,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  void _showCardSelectionBottomSheet(BuildContext context, List<CardModel> cards) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final ThemeData theme = Theme.of(context);
        final bool isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Select Card',
                  style: Font.montserratFont(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ...cards.map((CardModel card) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildAccountItem(
                    context: context,
                    card: card,
                    isSelected: _selectedCard?.id == card.id,
                    onTap: () {
                      setState(() {
                        _selectedCard = card;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )),
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
      },
    );
  }
}