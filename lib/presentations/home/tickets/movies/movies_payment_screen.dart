import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/constants/tax.dart';
import '../../../../core/theme/theme.dart';
import '../../../../data/models/card/card_model.dart';
import '../../../../data/models/tickets/movies_model.dart';
import '../../../../logic/blocs/add_card/card_bloc.dart';
import '../../../../logic/blocs/add_card/card_event.dart';
import '../../../../logic/blocs/add_card/card_state.dart';
import '../../../../logic/blocs/tickets/movies/movies_bloc.dart';
import '../../../../logic/blocs/tickets/movies/movies_event.dart';
import '../../../../logic/blocs/tickets/movies/movies_state.dart';
import '../../../../services/payment_service.dart';
import '../../../widgets/background_theme.dart';
import '../../../widgets/custom_button.dart';

class MoviePaymentScreen extends StatefulWidget {
  final MovieModel movie;

  const MoviePaymentScreen({super.key, required this.movie});

  @override
  State<MoviePaymentScreen> createState() => _MoviePaymentScreenState();
}

class _MoviePaymentScreenState extends State<MoviePaymentScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late AnimationController _backgroundAnimationController;

  DateTime _selectedDate = DateTime.now();
  String _selectedShowtime = '';
  int _numberOfTickets = 1;
  String _selectedSeatType = 'Regular';
  CardModel? _selectedCard;

  @override
  void initState() {
    super.initState();
    _selectedShowtime = widget.movie.showtimes.first;
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
    return widget.movie.ticketPrice * _numberOfTickets;
  }

  double get _seatUpgradeAmount {
    if (_selectedSeatType == 'Regular') return 0.0;
    final double basePrice = widget.movie.ticketPrice;
    final double seatMultiplier = _getSeatMultiplier(_selectedSeatType) - 1; // Subtract 1 to get only the upgrade cost
    return basePrice * seatMultiplier * _numberOfTickets;
  }

  double get _subtotal {
    return _baseTicketPrice + _seatUpgradeAmount;
  }

  double get _ticketTax {
    return _subtotal * (Taxes.ticketFeeTax / 100);
  }

  double get _totalAmount {
    return _subtotal + _ticketTax;
  }

  double _getSeatMultiplier(String seatType) {
    switch (seatType) {
      case 'IMAX':
        return 2.5;
      case 'Premium':
        return 1.8;
      case 'Recliner':
        return 1.5;
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Movie Tickets"),
        iconTheme: const IconThemeData(
          color: MyTheme.secondaryColor,
        ),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          BlocListener<MovieBookingBloc, MovieBookingState>(
            listener: (BuildContext context, MovieBookingState state) {
              if (state is MovieBookingSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).popUntil((Route route) => route.isFirst);
              } else if (state is MovieBookingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildMovieSummary(),
                    const SizedBox(height: 16),
                    _buildShowtimeSelection(),
                    const SizedBox(height: 16),
                    _buildCustomerDetails(),
                    const SizedBox(height: 16),
                    _buildTicketOptions(),
                    const SizedBox(height: 16),
                    _buildPaymentMethod(),
                    const SizedBox(height: 16),
                    _buildPriceBreakdown(),
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

  Widget _buildMovieSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Movie Summary",
            style: Font.montserratFont(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text("Movie: ${widget.movie.title}"),
          Text("Genre: ${widget.movie.genre}"),
          Text("Duration: ${widget.movie.duration}"),
          Text("Rating: ${widget.movie.rating}"),
          Text("Cinema: ${widget.movie.cinemaChain}"),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Text("Date: "),
              TextButton(
                onPressed: () async {
                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                child: Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  style: Font.montserratFont(color: MyTheme.secondaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShowtimeSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Select Showtime",
            style: Font.montserratFont(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.movie.showtimes.map((String time) =>
                ChoiceChip(
                  label: Text(time, style: Font.montserratFont(fontSize: 14,color: Colors.black),),
                  selected: _selectedShowtime == time,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedShowtime = time;
                      });
                    }
                  },
                  selectedColor: MyTheme.secondaryColor,
                  checkmarkColor: MyTheme.secondaryColor,
                ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Customer Details",
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
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextFormField(
            controller: _emailController,
            prefixIcon: const Icon(Icons.email,color: MyTheme.secondaryColor,),
            helpText: "Email",
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
    );
  }

  Widget _buildTicketOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Ticket Options",
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
                    const Text("Number of Tickets"),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: _numberOfTickets > 1
                              ? () {
                            setState(() {
                              _numberOfTickets--;
                            });
                          }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline,color: MyTheme.secondaryColor,),
                        ),
                        Text(
                          '$_numberOfTickets',
                          style: Font.montserratFont(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: _numberOfTickets < 10
                              ? () {
                            setState(() {
                              _numberOfTickets++;
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
                      items: <String>['Regular', 'Recliner', 'Premium', 'IMAX'].map((String type) => DropdownMenuItem(
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
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  width: 120.w,
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
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Price Breakdown",
            style: Font.montserratFont(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Tickets ($_numberOfTickets x \$${widget.movie.ticketPrice.toStringAsFixed(2)})"),
              Text("\$${_baseTicketPrice.toStringAsFixed(2)}"),
            ],
          ),
          if (_selectedSeatType != 'Regular') ...<Widget>[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("$_selectedSeatType Upgrade"),
                Text("\$${_seatUpgradeAmount.toStringAsFixed(2)}"),
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
    );
  }


  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<MovieBookingBloc, MovieBookingState>(
        builder: (BuildContext context, MovieBookingState state) {
          return AppButton(
            text: "${state is MovieBookingLoading ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ) :
            "Confirm Booking & Pay"}",
            color: MyTheme.secondaryColor,
            onTap: state is MovieBookingLoading ? null : _processBooking,
          );
          //   ElevatedButton(
          //   onPressed: state is MovieBookingLoading ? null : _processBooking,
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.red.shade700,
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(vertical: 16),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          //   child: state is MovieBookingLoading
          //       ? const SizedBox(
          //     height: 20,
          //     width: 20,
          //     child: CircularProgressIndicator(
          //       color: Colors.white,
          //       strokeWidth: 2,
          //     ),
          //   )
          //       : const Text(
          //     "Confirm Booking & Pay",
          //     style: Font.montserratFont(fontSize: 16),
          //   ),
          // );
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

      final MovieBookingModel booking = MovieBookingModel(
        id: const Uuid().v4(),
        movieId: widget.movie.id,
        movieTitle: widget.movie.title,
        cinemaChain: widget.movie.cinemaChain,
        customerName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        showDate: _selectedDate,
        showtime: _selectedShowtime,
        numberOfTickets: _numberOfTickets,
        seatType: _selectedSeatType,
        totalAmount: _totalAmount,
        baseTicketPrice: _baseTicketPrice,
        seatUpgradeAmount: _seatUpgradeAmount,
        taxAmount: _ticketTax,
        paymentStatus: 'completed',
        bookingDate: DateTime.now(),
      );

      context.read<MovieBookingBloc>().add(CreateMovieBooking(booking));
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
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Image.asset(
            card.brandIconPath,
            height: 24,
            width: 40,
            color: isDark ? Colors.white : Colors.black,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
            children: <Widget>[
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: MyTheme.secondaryColor
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
                    fontWeight: FontWeight.bold,
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