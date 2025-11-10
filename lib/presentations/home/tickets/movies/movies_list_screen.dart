import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/data/models/tickets/movies_model.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../logic/blocs/tickets/movies/movies_bloc.dart';
import '../../../../logic/blocs/tickets/movies/movies_event.dart';
import '../../../../logic/blocs/tickets/movies/movies_state.dart';
import '../../../widgets/background_theme.dart';
import 'movies_detail.dart';

class MovieListScreen extends StatefulWidget {
  MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> with TickerProviderStateMixin{
  List<String> moviesImage = <String>[
    "assets/images/movies/download (2).jpeg",
    "assets/images/movies/download.jpeg",
    "assets/images/movies/download (1).jpeg",
    "assets/images/movies/download (3).jpeg",
    "assets/images/movies/download (4).jpeg",
    "assets/images/movies/download (5).jpeg",
    "assets/images/movies/download (6).jpeg",
    "assets/images/movies/download (7).jpeg",
    "assets/images/movies/download (8).jpeg",
    "assets/images/movies/download (9).jpeg",
    "assets/images/movies/download (10).jpeg",
    "assets/images/movies/download (11).jpeg",
    "assets/images/movies/download (12).jpeg",
    "assets/images/movies/download (13).jpeg",
    "assets/images/movies/download (14).jpeg",
    "assets/images/movies/download (15).jpeg",
    "assets/images/movies/download (16).jpeg",
    "assets/images/movies/download (17).jpeg",
  ];
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
    // TODO: implement dispose
    super.dispose();
    _backgroundAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("US Cinemas & Movies"),
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MovieBloc>().add(InitializeMovies());
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          BlocBuilder<MovieBloc, MovieState>(
            builder: (BuildContext context, MovieState state) {
              if (state is MovieLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading movies...'),
                    ],
                  ),
                );
              }

              if (state is MovieError) {
                return Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (BuildContext context, double value, Widget? child) {
                            return Transform.scale(
                              scale: value,
                              child: Icon(
                                Icons.error,
                                size: 64,
                                color: Colors.red.shade400,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        FadeTransition(
                          opacity: const AlwaysStoppedAnimation(1.0),
                          child: Text(state.message, textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 16),
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<MovieBloc>().add(LoadMovies());
                            },
                            child: const Text('Retry'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is MovieLoaded) {
                return AnimatedList(
                  padding: const EdgeInsets.all(8),
                  initialItemCount: state.movies.length,
                  itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                    if (index >= state.movies.length) return const SizedBox.shrink();

                    final MovieModel movie = state.movies[index];
                    return SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
                          CurveTween(curve: Curves.easeOutCubic),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: animation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _AnimatedMovieCard(
                            movie: movie,
                            index: index,
                            imageURL: moviesImage[index],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              return const Center(child: Text('No movies available'));
            },
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

class _AnimatedMovieCard extends StatefulWidget {
  final dynamic movie; // Replace with your Movie model type
  final int index;
  final String imageURL;

  const _AnimatedMovieCard({
    required this.movie,
    required this.index,
    required this.imageURL,
  });

  @override
  State<_AnimatedMovieCard> createState() => _AnimatedMovieCardState();
}

class _AnimatedMovieCardState extends State<_AnimatedMovieCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Add a staggered delay for initial animation
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _shimmerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            elevation: _isPressed ? 2 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                onTap: () {
                  HapticFeedback.lightImpact();

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => MovieDetailScreen(movie: widget.movie, imageUrl: widget.imageURL,),
                      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic)),
                          ),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Hero(
                        tag: 'movie_poster_${widget.movie.title}',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade300,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(widget.imageURL.toString(),fit: BoxFit.cover,),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      /// Movie Details with staggered animations
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 400 + (widget.index * 50)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (BuildContext context, double value, Widget? child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: Text(
                                      widget.movie.title,
                                      style: Font.montserratFont(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 500 + (widget.index * 50)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (BuildContext context, double value, Widget? child) {
                                return Transform.translate(
                                  offset: Offset(0, 15 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: Text(
                                      widget.movie.genre,
                                      style: Font.montserratFont(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 2),

                            // Animated Rating Badge
                            TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 600 + (widget.index * 50)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (BuildContext context, double value, Widget? child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Row(
                                    children: <Widget>[
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getRatingColor(widget.movie.rating),
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: _getRatingColor(widget.movie.rating).withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          widget.movie.rating,
                                          style: Font.montserratFont(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.movie.duration,
                                        style: Font.montserratFont(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),

                            // Animated Star Rating
                            TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 700 + (widget.index * 50)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (BuildContext context, double value, Widget? child) {
                                return Transform.translate(
                                  offset: Offset(0, 10 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: Row(
                                      children: <Widget>[
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(milliseconds: 400),
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          builder: (BuildContext context, double rotateValue, Widget? child) {
                                            return Transform.rotate(
                                              angle: rotateValue * 2 * 3.14159,
                                              child: const Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${widget.movie.imdbRating}/10",
                                          style: Font.montserratFont(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),

                            // Animated Showtimes
                            TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 800 + (widget.index * 50)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (BuildContext context, double value, Widget? child) {
                                return Transform.translate(
                                  offset: Offset(0, 10 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: Text(
                                      "Showtimes: ${widget.movie.showtimes.take(3).join(', ')}",
                                      style: Font.montserratFont(
                                        color: Colors.blue.shade600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      /// Animated Price
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 600 + (widget.index * 50)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (BuildContext context, double value, Widget? child) {
                          return Transform.scale(
                            scale: value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: MyTheme.secondaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "\$${widget.movie.ticketPrice.toStringAsFixed(2)}",
                                    style: Font.montserratFont(
                                      fontWeight: FontWeight.bold,
                                      color: MyTheme.secondaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "per ticket",
                                  style: Font.montserratFont(
                                    color: Colors.grey.shade500,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
