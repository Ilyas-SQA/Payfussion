import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/presentations/home/tickets/train/train_detail_screen.dart';
import '../../../../data/models/tickets/train_model.dart';
import '../../../../logic/blocs/tickets/train/train_bloc.dart';
import '../../../../logic/blocs/tickets/train/train_event.dart';
import '../../../../logic/blocs/tickets/train/train_state.dart';
import '../../../widgets/background_theme.dart';

class TrainListScreen extends StatefulWidget {
  const TrainListScreen({super.key});

  @override
  State<TrainListScreen> createState() => _TrainListScreenState();
}

class _TrainListScreenState extends State<TrainListScreen> with TickerProviderStateMixin {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("US Train Services"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TrainBloc>().add(InitializeTrains());
            },
          ),
        ],
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          BlocBuilder<TrainBloc, TrainState>(
            builder: (BuildContext context, TrainState state) {
              if (state is TrainLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading trains...'),
                    ],
                  ),
                );
              }

              if (state is TrainError) {
                return Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0, end: 1),
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
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<TrainBloc>().add(LoadTrains());
                            },
                            child: const Text('Retry'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is TrainLoaded) {
                return AnimatedList(
                  padding: const EdgeInsets.all(8),
                  initialItemCount: state.trains.length,
                  itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                    if (index >= state.trains.length) return const SizedBox.shrink();

                    final TrainModel train = state.trains[index];

                    return SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(1, 0), end: Offset.zero).chain(
                          CurveTween(curve: Curves.easeOutCubic),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: animation.drive(
                          CurveTween(curve: Curves.easeIn),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: index == state.trains.length - 1 ? 0 : 8,
                          ),
                          child: AnimatedTrainCard(
                            train: train,
                            index: index,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              return FadeInUp(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.train,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No trains available',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnimatedTrainCard extends StatefulWidget {
  final TrainModel train;
  final int index;

  const AnimatedTrainCard({
    super.key,
    required this.train,
    required this.index,
  });

  @override
  State<AnimatedTrainCard> createState() => _AnimatedTrainCardState();
}

class _AnimatedTrainCardState extends State<AnimatedTrainCard> with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
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
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                        TrainDetailScreen(train: widget.train),
                    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                              .chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
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
                  child: Row(
                    children: <Widget>[
                      Hero(
                        tag: 'train-icon-${widget.train.name}',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.train,
                            color: MyTheme.secondaryColor,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Hero(
                              tag: 'train-name-${widget.train.name}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  widget.train.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FadeInUp(
                              delay: Duration(milliseconds: 100 + (widget.index * 50)),
                              child: Text(
                                widget.train.route,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (widget.train.via.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 2),
                              FadeInUp(
                                delay: Duration(milliseconds: 150 + (widget.index * 50)),
                                child: Text(
                                  "Via: ${widget.train.via}",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            FadeInUp(
                              delay: Duration(milliseconds: 200 + (widget.index * 50)),
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: MyTheme.secondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${widget.train.duration.inHours}h ${widget.train.duration.inMinutes % 60}m",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 100 + (widget.index * 50)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isPressed
                                    ? Colors.green.shade700
                                    : Colors.green.shade600,
                                fontSize: _isPressed ? 19 : 18,
                              ),
                              child: Text(
                                "\$${widget.train.approxCostUSD.toStringAsFixed(0)}",
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "per person",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
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
}

/// Helper Widget for Fade In Up Animation
class FadeInUp extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const FadeInUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ));

    _position = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _position,
            child: widget.child,
          ),
        );
      },
    );
  }
}


