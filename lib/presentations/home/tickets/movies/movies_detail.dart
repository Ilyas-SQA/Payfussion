import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';
import '../../../../data/models/tickets/movies_model.dart';
import '../../../widgets/background_theme.dart';
import 'movies_payment_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;
  final String imageUrl;

  const MovieDetailScreen({super.key, required this.movie, required this.imageUrl});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _buttonController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _backgroundAnimationController;

  String? _selectedShowtime;
  bool _isBookingPressed = false;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    // Main animation controller for page entrance
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Button animation controller
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Shimmer controller for loading states
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Setup animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    // Start the main animation
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _buttonController.dispose();
    _shimmerController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _onBookingPressed() {
    setState(() => _isBookingPressed = true);
    _buttonController.forward();
    HapticFeedback.mediumImpact();
  }

  void _onBookingReleased() {
    setState(() => _isBookingPressed = false);
    _buttonController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Text(widget.movie.title),
            );
          },
        ),
        iconTheme: const IconThemeData(
          color: MyTheme.secondaryColor,
        ),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          AnimatedBuilder(
            animation: _mainController,
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Main Movie Info Card
                        _AnimatedCard(
                          delay: 0,
                          controller: _mainController,
                          child: _buildMainInfoCard(widget.imageUrl),
                        ),

                        const SizedBox(height: 20),

                        // Synopsis Card
                        if (widget.movie.synopsis.isNotEmpty) ...<Widget>[
                          _AnimatedCard(
                            delay: 200,
                            controller: _mainController,
                            child: _buildSynopsisCard(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Cast Card
                        if (widget.movie.cast.isNotEmpty) ...<Widget>[
                          _AnimatedCard(
                            delay: 400,
                            controller: _mainController,
                            child: _buildCastCard(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Showtimes Card
                        _AnimatedCard(
                          delay: 600,
                          controller: _mainController,
                          child: _buildShowtimesCard(),
                        ),

                        const SizedBox(height: 24),

                        // Animated Book Button
                        _buildAnimatedBookButton(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard(String imageURl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
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
        ),        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Animated Poster with Hero
              Hero(
                tag: 'movie_poster_${widget.movie.title}',
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (BuildContext context, double value, Widget? child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade300,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(imageURl,fit: BoxFit.cover,)
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Movie Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Title with typing animation
                    TweenAnimationBuilder<int>(
                      duration: const Duration(milliseconds: 1000),
                      tween: IntTween(begin: 0, end: widget.movie.title.length),
                      builder: (BuildContext context, int value, Widget? child) {
                        return Text(
                          widget.movie.title.substring(0, value),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Animated detail rows
                    ..._buildAnimatedDetailRows(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (BuildContext context, Widget? child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: <double>[
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ].map((double e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            Icons.movie,
            size: 60,
            color: Colors.grey.shade600,
          ),
        );
      },
    );
  }

  List<Widget> _buildAnimatedDetailRows() {
    final List<(IconData, String, String)> details = <(IconData, String, String)>[
      (Icons.category, "Genre", widget.movie.genre),
      (Icons.access_time, "Duration", widget.movie.duration),
      (Icons.calendar_today, "Release Date", widget.movie.releaseDate),
      (Icons.star, "IMDB Rating", "${widget.movie.imdbRating}/10"),
      (Icons.theaters, "Cinema Chain", widget.movie.cinemaChain),
    ];

    return details.asMap().entries.map((MapEntry<int, (IconData, String, String)> entry) {
      final int index = entry.key;
      final (IconData, String, String) detail = entry.value;

      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 600 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: _buildDetailRow(detail.$1, detail.$2, detail.$3),
            ),
          );
        },
      );
    }).toList()
      ..add(
        // Animated rating badge
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (BuildContext context, double value, Widget? child) {
            return Transform.scale(
              scale: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRatingColor(widget.movie.rating),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: _getRatingColor(widget.movie.rating).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.movie.rating,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
  }

  Widget _buildSynopsisCard() {
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
          const Text(
            "Synopsis",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<int>(
            duration: const Duration(milliseconds: 2000),
            tween: IntTween(begin: 0, end: widget.movie.synopsis.length),
            builder: (BuildContext context, int value, Widget? child) {
              return Text(
                widget.movie.synopsis.substring(0, value),
                style: const TextStyle(height: 1.5),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCastCard() {
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
          const Text(
            "Cast",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.movie.cast.asMap().entries.map((MapEntry<int, String> entry) {
              final int index = entry.key;
              final String actor = entry.value;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: MyTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: MyTheme.secondaryColor,),
                      ),
                      child: Text(
                        actor,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShowtimesCard() {
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
          const Text(
            "Available Showtimes",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.movie.showtimes.asMap().entries.map((MapEntry<int, String> entry) {
              final int index = entry.key;
              final String time = entry.value;
              final bool isSelected = _selectedShowtime == time;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 50)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedShowtime = isSelected ? null : time;
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? MyTheme.secondaryColor : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: MyTheme.secondaryColor),
                        ),
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBookButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: AnimatedBuilder(
              animation: _buttonController,
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: 1.0 - (_buttonController.value * 0.05),
                  child: GestureDetector(
                    onTapDown: (_) => _onBookingPressed(),
                    onTapUp: (_) => _onBookingReleased(),
                    onTapCancel: _onBookingReleased,
                    child: AppButton(
                      text: _selectedShowtime != null ? "Book Tickets for $_selectedShowtime" : "Select Showtime to Book",
                      color: _selectedShowtime != null ? MyTheme.secondaryColor : Colors.grey.shade400,
                      onTap: _selectedShowtime != null ? () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                                MoviePaymentScreen(movie: widget.movie),
                            transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                              return SlideTransition(
                                position: animation.drive(
                                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                                ),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      } : null,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: MyTheme.secondaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12,color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,),
                children: <InlineSpan>[
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(String rating) {
    switch (rating.toUpperCase()) {
      case 'G':
        return Colors.green.shade600;
      case 'PG':
        return Colors.blue.shade600;
      case 'PG-13':
        return Colors.orange.shade600;
      case 'R':
        return Colors.red.shade600;
      case 'NC-17':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}

// Custom animated card widget
class _AnimatedCard extends StatelessWidget {
  final Widget child;
  final int delay;
  final AnimationController controller;

  const _AnimatedCard({
    required this.child,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: this.child,
          ),
        );
      },
    );
  }
}