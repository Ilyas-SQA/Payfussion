import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/services/payment_service.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/tax.dart';
import '../../../../data/models/card/card_model.dart';
import '../../../../data/models/notification/notification_model.dart';
import '../../../../data/models/tickets/flight_model.dart';
import '../../../../logic/blocs/add_card/card_bloc.dart';
import '../../../../logic/blocs/add_card/card_event.dart';
import '../../../../logic/blocs/add_card/card_state.dart';
import '../../../../logic/blocs/notification/notification_bloc.dart';
import '../../../../logic/blocs/notification/notification_event.dart';
import '../../../../logic/blocs/notification/notification_state.dart';
import '../../../../logic/blocs/tickets/flight/flight_bloc.dart';
import '../../../../logic/blocs/tickets/flight/flight_event.dart';
import '../../../../logic/blocs/tickets/flight/flight_state.dart';
import '../../../widgets/custom_button.dart';


class FlightPaymentScreen extends StatefulWidget {
  final FlightModel flight;

  const FlightPaymentScreen({super.key, required this.flight});

  @override
  State<FlightPaymentScreen> createState() => _FlightPaymentScreenState();
}

class _FlightPaymentScreenState extends State<FlightPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _numberOfPassengers = 1;
  String _selectedClass = 'Economy';
  CardModel? _selectedCard;

  @override
  void initState() {
    super.initState();
    context.read<CardBloc>().add(LoadCards());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double get _baseFare {
    return widget.flight.basePrice * _numberOfPassengers;
  }

  double get _classUpgradeAmount {
    if (_selectedClass == 'Economy') return 0.0;
    double basePrice = widget.flight.basePrice;
    double classMultiplier = _getClassMultiplier(_selectedClass) - 1; // Subtract 1 to get only the upgrade cost
    return basePrice * classMultiplier * _numberOfPassengers;
  }

  double get _subtotal {
    return _baseFare + _classUpgradeAmount;
  }

  double get _ticketTax {
    return _subtotal * (Taxes.ticketFeeTax / 100);
  }

  double get _totalAmount {
    return _subtotal + _ticketTax;
  }

  double _getClassMultiplier(String flightClass) {
    switch (flightClass) {
      case 'First Class':
        return 3.0;
      case 'Business':
        return 2.0;
      case 'Premium Economy':
        return 1.5;
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Flight Ticket"),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FlightBookingBloc, FlightBookingState>(
            listener: (context, state) {
              if (state is FlightBookingSuccess) {
                // Add notification when flight booking is successful
                _addFlightNotification(
                  success: true,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (state is FlightBookingError) {
                // Add notification when flight booking fails
                _addFlightNotification(
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
            listener: (context, state) {
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
              children: [
                _buildFlightSummary(),
                const SizedBox(height: 16),
                _buildPassengerDetails(),
                const SizedBox(height: 16),
                _buildFlightOptions(),
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
    );
  }

  // Add this method to create flight notifications
  void _addFlightNotification({
    required bool success,
    String? bookingId,
    String? errorMessage,
  }) {
    final notification = NotificationModel.createFlightNotification(
      airline: widget.flight.airline,
      flightNumber: widget.flight.flightNumber,
      passengerName: _nameController.text,
      departureAirport: widget.flight.departureAirport,
      arrivalAirport: widget.flight.arrivalAirport,
      travelDate: _selectedDate,
      numberOfPassengers: _numberOfPassengers,
      totalAmount: _totalAmount,
      travelClass: _selectedClass,
      bookingId: bookingId,
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

  Widget _buildFlightSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Flight Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text("Airline: ${widget.flight.airline}"),
            Text("Flight: ${widget.flight.flightNumber}"),
            Text("Aircraft: ${widget.flight.aircraft}"),
            Text("Route: ${widget.flight.departureAirport} → ${widget.flight.arrivalAirport}"),
            Text("Duration: ${widget.flight.duration}"),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Travel Date: "),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
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
                    style: TextStyle(color: Colors.blue.shade700),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Passenger Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                hintText: "Enter passenger name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter passenger name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "Enter email address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
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
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                hintText: "Enter phone number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
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

  Widget _buildFlightOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Flight Options",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Number of Passengers"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _numberOfPassengers > 1
                                ? () {
                              setState(() {
                                _numberOfPassengers--;
                              });
                            }
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '$_numberOfPassengers',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: _numberOfPassengers < 9
                                ? () {
                              setState(() {
                                _numberOfPassengers++;
                              });
                            }
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Travel Class"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedClass,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: ['Economy', 'Premium Economy', 'Business', 'First Class']
                            .map((cls) => DropdownMenuItem(
                          value: cls,
                          child: Text(cls),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClass = value!;
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10,
              children: [
                const Text(
                  "Payment Method",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: CustomButton(
                    height: 35.h,
                    backgroundColor: AppColors.primaryBlue,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fare Breakdown",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Base Fare ($_numberOfPassengers passenger${_numberOfPassengers > 1 ? 's' : ''})"),
                Text("\$${_baseFare.toStringAsFixed(2)}"),
              ],
            ),
            if (_selectedClass != 'Economy') ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$_selectedClass Upgrade"),
                  Text("\$${_classUpgradeAmount.toStringAsFixed(2)}"),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal"),
                Text("\$${_subtotal.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ticket Tax (${Taxes.ticketFeeTax}%)"),
                Text("\$${_ticketTax.toStringAsFixed(2)}"),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Amount",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\$${_totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
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
      child: BlocBuilder<FlightBookingBloc, FlightBookingState>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state is FlightBookingLoading ? null : _processBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: state is FlightBookingLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              "Confirm Booking & Pay",
              style: TextStyle(fontSize: 16),
            ),
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

      final booking = FlightBookingModel(
        id: const Uuid().v4(),
        flightId: widget.flight.id,
        airline: widget.flight.airline,
        flightNumber: widget.flight.flightNumber,
        passengerName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        travelDate: _selectedDate,
        numberOfPassengers: _numberOfPassengers,
        totalAmount: _totalAmount,
        baseFare: _baseFare,
        classUpgradeAmount: _classUpgradeAmount,
        taxAmount: _ticketTax,
        paymentStatus: 'completed',
        bookingDate: DateTime.now(),
        travelClass: _selectedClass,
        departureAirport: widget.flight.departureAirport,
        arrivalAirport: widget.flight.arrivalAirport,
        departureTime: widget.flight.departureTime,
        arrivalTime: widget.flight.arrivalTime,
      );

      context.read<FlightBookingBloc>().add(CreateFlightBooking(booking));
    }
  }

  Widget _buildCardsSection() {
    return BlocBuilder<CardBloc, CardState>(
      builder: (context, state) {
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
              child: const Center(
                child: Text(
                  'No cards available. Please add a card first.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }

          if (_selectedCard == null) {
            _selectedCard = state.cards.firstWhere(
                  (card) => card.isDefault,
              orElse: () => state.cards.first,
            );
          }

          return Column(
            children: [
              _buildAccountItem(
                context: context,
                card: _selectedCard!,
                isSelected: true,
                onTap: () {
                  _showCardSelectionBottomSheet(context, state.cards);
                },
              ),
              if (_selectedCard != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Tap to change card',
                  style: TextStyle(
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
                children: [
                  const Text(
                    'Error loading cards',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<CardBloc>().add(LoadCards());
                    },
                    child: const Text('Retry', style: TextStyle(fontSize: 10)),
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

  Widget _buildAccountItem({
    required BuildContext context,
    required CardModel card,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          border: isSelected
              ? Border.all(color: const Color(0xff3862F8), width: 2)
              : Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Image.asset(
            card.brandIconPath,
            height: 24,
            width: 40,
            color: isDark ? Colors.white : Colors.black,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/icons/mastercard.png',
                height: 24,
                width: 40,
              );
            },
          ),
          title: Text(
            card.cardEnding,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            'Exp: ${card.formattedExpiry}${card.isDefault ? ' • Default' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Color(0xff3862F8),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCardSelectionBottomSheet(BuildContext context, List<CardModel> cards) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final ThemeData theme = Theme.of(context);
        final bool isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Card',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...cards.map((card) => Padding(
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