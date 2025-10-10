import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/presentations/pay_bills/widgets/section_header.dart';

import '../../../core/constants/image_url.dart';
import '../../../core/theme/theme.dart';
import 'bus/bus_screen.dart';
import 'car/car_screen.dart';
import 'flight/flight_screen.dart';
import 'movies/movies_list_screen.dart';

class TicketBookingScreen extends StatefulWidget {
  const TicketBookingScreen({super.key});

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _cardController;
  late AnimationController _quickAccessController;
  late AnimationController _billsController;
  late AnimationController _ticketsController;

  late Animation<double> _ticketsFade;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _quickAccessController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _billsController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _ticketsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _ticketsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ticketsController, curve: Curves.easeOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _cardController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _quickAccessController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _billsController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _ticketsController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    _quickAccessController.dispose();
    _billsController.dispose();
    _ticketsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Ticket"),
      ),
      body: FadeTransition(
        opacity: _ticketsFade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_ticketsController),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SectionHeader(
                  title: "Ticket Booking",
                  onActionPressed: () {},
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: _buildTicketBookingList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketBookingList() {
    final ThemeData theme = Theme.of(context);

    final ticketItems = [
      {
        'icon': TImageUrl.iconMovies,
        'label': 'Movies',
        'subtitle': 'Book movie tickets',
        'color': MyTheme.primaryColor,
        'iconColor': Colors.white,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => MovieListScreen()))
      },
      {
        'icon': TImageUrl.iconTrains,
        'label': 'Trains',
        'subtitle': 'Railway reservations',
        'color': MyTheme.primaryColor,
        'iconColor': Colors.white,
        'onTap': () => context.push(RouteNames.trainListScreen)
      },
      {
        'icon': TImageUrl.iconBus,
        'label': 'Bus',
        'subtitle': 'Bus ticket booking',
        'color': MyTheme.primaryColor,
        'iconColor': Colors.white,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => BusListScreen()))
      },
      {
        'icon': TImageUrl.iconFlight,
        'label': 'Flights',
        'subtitle': 'Domestic & international flights',
        'color': MyTheme.primaryColor,
        'iconColor': Colors.white,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => FlightListScreen()))
      },
      {
        'icon': TImageUrl.iconCar,
        'label': 'Car Rental',
        'subtitle': 'Book rides & car rentals',
        'color': MyTheme.primaryColor,
        'iconColor': Colors.white,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => RideServiceListScreen()))
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AnimationLimiter(
        child: ListView.builder(
          itemCount: ticketItems.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildTicketListItem(
                    ticketItems[index],
                    theme,
                    index,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTicketListItem(Map<String, dynamic> item, ThemeData theme, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item['onTap'] as VoidCallback,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                // Icon Container
                Container(
                  height: 60.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Image.asset(
                      item['icon'] as String,
                      height: 32.h,
                      width: 32.w,
                      color: item['iconColor'] as Color,
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor != Colors.white
                              ? const Color(0xffffffff)
                              : const Color(0xff2D3748),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item['subtitle'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor != Colors.white
                              ? const Color(0xffffffff).withOpacity(0.7)
                              : const Color(0xff718096),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: theme.primaryColor != Colors.white
                      ? const Color(0xffffffff).withOpacity(0.5)
                      : const Color(0xffA0AEC0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Alternative Grid Layout Version
class TicketBookingGridScreen extends StatefulWidget {
  const TicketBookingGridScreen({super.key});

  @override
  State<TicketBookingGridScreen> createState() => _TicketBookingGridScreenState();
}

class _TicketBookingGridScreenState extends State<TicketBookingGridScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ticketItems = [
      {
        'icon': TImageUrl.iconMovies,
        'label': 'Movies',
        'color': Colors.red.withOpacity(0.1),
        'iconColor': Colors.red,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => MovieListScreen()))
      },
      {
        'icon': TImageUrl.iconTrains,
        'label': 'Trains',
        'color': Colors.blue.withOpacity(0.1),
        'iconColor': Colors.blue,
        'onTap': () => context.push(RouteNames.trainListScreen)
      },
      {
        'icon': TImageUrl.iconBus,
        'label': 'Bus',
        'color': Colors.green.withOpacity(0.1),
        'iconColor': Colors.green,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => BusListScreen()))
      },
      {
        'icon': TImageUrl.iconFlight,
        'label': 'Flights',
        'color': Colors.orange.withOpacity(0.1),
        'iconColor': Colors.orange,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => FlightListScreen()))
      },
      {
        'icon': TImageUrl.iconCar,
        'label': 'Car Rental',
        'color': Colors.purple.withOpacity(0.1),
        'iconColor': Colors.purple,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => RideServiceListScreen()))
      },
    ];

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SectionHeader(
                title: "Ticket Booking",
                onActionPressed: () {},
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: AnimationLimiter(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                    ),
                    itemCount: ticketItems.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        columnCount: 2,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: _buildGridTicketItem(
                              ticketItems[index],
                              theme,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTicketItem(Map<String, dynamic> item, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item['onTap'] as VoidCallback,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 60.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Center(
                    child: Image.asset(
                      item['icon'] as String,
                      height: 32.h,
                      width: 32.w,
                      color: item['iconColor'] as Color,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  item['label'] as String,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor != Colors.white
                        ? const Color(0xffffffff)
                        : const Color(0xff2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}