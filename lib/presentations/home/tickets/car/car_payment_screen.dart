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
import '../../../../data/models/tickets/car_model.dart';
import '../../../../logic/blocs/add_card/card_bloc.dart';
import '../../../../logic/blocs/add_card/card_event.dart';
import '../../../../logic/blocs/add_card/card_state.dart';
import '../../../../logic/blocs/notification/notification_bloc.dart';
import '../../../../logic/blocs/notification/notification_event.dart';
import '../../../../logic/blocs/notification/notification_state.dart';
import '../../../../logic/blocs/tickets/car/car_bloc.dart';
import '../../../../logic/blocs/tickets/car/car_event.dart';
import '../../../../logic/blocs/tickets/car/car_state.dart';
import '../../../widgets/background_theme.dart';
import '../../../widgets/custom_button.dart';


class RideBookingScreen extends StatefulWidget {
  final RideModel ride;

  const RideBookingScreen({super.key, required this.ride});

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> with TickerProviderStateMixin{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late AnimationController _backgroundAnimationController;

  DateTime _selectedDateTime = DateTime.now().add(const Duration(minutes: 15));
  String _rideType = 'Now';
  double _estimatedDistance = 5.0;
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
    _pickupController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  double get _baseFare {
    return widget.ride.baseRate * _estimatedDistance;
  }

  double get _schedulingFee {
    return _rideType == 'Scheduled' ? 2.00 : 0.00;
  }

  double get _subtotal {
    return _baseFare + _schedulingFee;
  }

  double get _ticketTax {
    return _subtotal * (Taxes.ticketFeeTax / 100);
  }

  double get _estimatedFare {
    return _subtotal + _ticketTax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Ride"),
        iconTheme: const IconThemeData(
          color: MyTheme.secondaryColor,
        ),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          MultiBlocListener(
            listeners: <SingleChildWidget>[
              BlocListener<RideBookingBloc, RideBookingState>(
                listener: (BuildContext context, RideBookingState state) {
                  if (state is RideBookingSuccess) {
                    // Add notification when ride booking is successful
                    _addRideNotification(
                      success: true,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).popUntil((Route route) => route.isFirst);
                  } else if (state is RideBookingError) {
                    // Add notification when ride booking fails
                    _addRideNotification(
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
                    _buildRideSummary(),
                    const SizedBox(height: 16),
                    _buildLocationDetails(),
                    const SizedBox(height: 16),
                    _buildRideOptions(),
                    const SizedBox(height: 16),
                    _buildPassengerDetails(),
                    const SizedBox(height: 16),
                    _buildPaymentMethod(),
                    const SizedBox(height: 16),
                    _buildFareEstimate(),
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

  void _addRideNotification({required bool success, String? bookingId, String? errorMessage,}) {
    final NotificationModel notification = NotificationModel.createRideNotification(
      driverName: widget.ride.driverName,
      serviceType: widget.ride.serviceType,
      passengerName: _nameController.text,
      pickupLocation: _pickupController.text,
      destination: _destinationController.text,
      estimatedFare: _estimatedFare,
      rideType: _rideType,
      scheduledDateTime: _rideType == 'Scheduled' ? _selectedDateTime : null,
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

  Widget _buildRideSummary() {
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
              "Ride Summary",
              style: Font.montserratFont(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getServiceColor(widget.ride.serviceType),
                  child: Text(
                    widget.ride.driverName.substring(0, 2).toUpperCase(),
                    style:  Font.montserratFont(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.ride.driverName,
                        style:  Font.montserratFont(fontWeight: FontWeight.bold),
                      ),
                      Text("${widget.ride.carMake} ${widget.ride.carModel}"),
                      Text("${widget.ride.serviceType} • ★${widget.ride.rating}"),
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

  Widget _buildLocationDetails() {
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
              "Trip Details",
              style: Font.montserratFont(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _pickupController,
              helpText: "Pickup Location",
              prefixIcon: const Icon(Icons.my_location, color: Colors.green),
              useGreenColor: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pickup location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _destinationController,
              helpText: "Destination",
              prefixIcon: const Icon(Icons.place, color: Colors.red),
              useGreenColor: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter destination';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text("Estimated Distance"),
                      const SizedBox(height: 8),
                      Slider(
                        value: _estimatedDistance,
                        min: 1.0,
                        max: 50.0,
                        divisions: 49,
                        label: "${_estimatedDistance.toStringAsFixed(1)} miles",
                        activeColor: MyTheme.secondaryColor,
                        onChanged: (double value) {
                          setState(() {
                            _estimatedDistance = value;
                          });
                        },
                      ),
                      Text(
                        "${_estimatedDistance.toStringAsFixed(1)} miles",
                        style:  Font.montserratFont(fontWeight: FontWeight.bold),
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

  Widget _buildRideOptions() {
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
              "Ride Options",
              style: Font.montserratFont(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text("Book Now"),
              subtitle: const Text("Immediate pickup"),
              value: "Now",
              groupValue: _rideType,
              activeColor: MyTheme.secondaryColor,
              onChanged: (String? value) {
                setState(() {
                  _rideType = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text("Schedule"),
              subtitle: const Text("Book for later"),
              value: "Scheduled",
              groupValue: _rideType,
              activeColor: MyTheme.secondaryColor,
              onChanged: (String? value) {
                setState(() {
                  _rideType = value!;
                });
              },
            ),
            if (_rideType == 'Scheduled') ...<Widget>[
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text("Pickup Time"),
                subtitle: Text(
                  "${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} at ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}",
                ),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 7)),
                  );
                  if (date != null) {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _notesController,
              helpText: "Special Instructions (Optional)",
              prefixIcon: const Icon(Icons.note,color: MyTheme.secondaryColor),
              useGreenColor: true,
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
              helpText: "Passenger Name",
              prefixIcon: const Icon(Icons.person,color: MyTheme.secondaryColor,),
              useGreenColor: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter passenger name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _phoneController,
              helpText: "Phone Number",
              prefixIcon: const Icon(Icons.phone,color: MyTheme.secondaryColor),
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

  bool _isAddingCard = false;


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
                    onPressed: _isAddingCard
                        ? null
                        : () async {
                      setState(() {
                        _isAddingCard = true;
                      });

                      try {
                        await PaymentService().saveCard(context);
                      } catch (e) {
                        // Error handling
                        print('Error: $e');
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isAddingCard = false;
                          });
                        }
                      }
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

  Widget _buildFareEstimate() {
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
              "Fare Estimate",
              style: Font.montserratFont(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Base fare (${_estimatedDistance.toStringAsFixed(1)} miles × \$${widget.ride.baseRate.toStringAsFixed(2)})"),
                Text("\$${_baseFare.toStringAsFixed(2)}"),
              ],
            ),
            if (_rideType == 'Scheduled') ...<Widget>[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Scheduling fee"),
                  Text("\$${_schedulingFee.toStringAsFixed(2)}"),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text("Subtotal"),
                Text("\$${_subtotal.toStringAsFixed(2)}"),
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
                  "Estimated Total",
                  style: Font.montserratFont(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\$${_estimatedFare.toStringAsFixed(2)}",
                  style: Font.montserratFont(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "* Final fare may vary based on actual distance, time, and traffic conditions",
              style: Font.montserratFont(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return BlocBuilder<RideBookingBloc, RideBookingState>(
      builder: (BuildContext context, RideBookingState state) {
        return AppButton(
          text: "${state is RideBookingLoading ?
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),) :
          _rideType == 'Now' ? "Book Ride Now" : "Schedule Ride"}",
          color: MyTheme.secondaryColor,
          onTap: state is RideBookingLoading ? null : _processBooking,
        );
      },
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

      final RideBookingModel booking = RideBookingModel(
        id: const Uuid().v4(),
        rideId: widget.ride.id,
        driverName: widget.ride.driverName,
        serviceType: widget.ride.serviceType,
        passengerName: _nameController.text,
        passengerPhone: _phoneController.text,
        pickupLocation: _pickupController.text,
        destination: _destinationController.text,
        estimatedDistance: _estimatedDistance,
        estimatedFare: _estimatedFare,
        baseFare: _baseFare,
        schedulingFee: _schedulingFee,
        taxAmount: _ticketTax,
        rideType: _rideType,
        scheduledDateTime: _rideType == 'Scheduled' ? _selectedDateTime : DateTime.now(),
        specialInstructions: _notesController.text,
        paymentStatus: 'completed',
        bookingDate: DateTime.now(),
        status: 'confirmed',
      );

      context.read<RideBookingBloc>().add(CreateRideBooking(booking));
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
                onTap: () {},
              ),
              if (_selectedCard != null) ...<Widget>[
                const SizedBox(height: 8),
                 GestureDetector(
                   onTap: (){
                     _showCardSelectionBottomSheet(context, state.cards);
                   },
                   child: Text(
                    'Tap to change card',
                    style: Font.montserratFont(
                      fontSize: 10,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
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
                  style: theme.textTheme.titleLarge?.copyWith(
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
                  child: AppButton(
                    onTap: () => Navigator.pop(context),
                    color: MyTheme.secondaryColor,
                    text: 'Cancel',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'uber':
        return Colors.black;
      case 'lyft':
        return Colors.pink.shade600;
      case 'taxi':
        return Colors.yellow.shade700;
      case 'limousine':
        return Colors.purple.shade600;
      case 'shuttle':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}