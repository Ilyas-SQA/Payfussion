import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/presentations/home/home/boxses_widget.dart';
import 'package:payfussion/presentations/home/home/card_list.dart';
import '../../../core/constants/fonts.dart';
import '../../../core/constants/routes_name.dart';
import '../../../logic/blocs/notification/notification_bloc.dart';
import '../../../logic/blocs/notification/notification_state.dart';
import '../../../services/session_manager_service.dart';
import '../../my_reward/my_reward_screen.dart';
import '../../notification/notification_screen.dart';
import '../../widgets/background_theme.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _profileAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _actionButtonsController;
  late AnimationController _transactionController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _actionButtonsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  void _initializeAnimations() {
    /// Profile animation
    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    /// Card animation
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    /// Action buttons animation
    _actionButtonsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    /// Transaction animation
    _transactionController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    /// Action buttons animation
    _actionButtonsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _actionButtonsController,
      curve: Curves.easeOutBack,
    ));

  }

  void _startAnimationSequence() async {
    await _profileAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _cardAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _actionButtonsController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _transactionController.forward();
  }

  ValueNotifier<bool> visible = ValueNotifier(false);
  String amount = "5000";


  @override
  void dispose() {
    _profileAnimationController.dispose();
    _cardAnimationController.dispose();
    _actionButtonsController.dispose();
    _transactionController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 70),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: <BoxShadow>[
               BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    spacing: 10,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => context.push(RouteNames.profile),
                        child: Hero(
                          tag: 'profile_avatar',
                          child: Center(
                            child: Container(
                              width: 45.r,
                              height: 45.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: (SessionController.user.profileImageUrl != null &&
                                    SessionController.user.profileImageUrl!.isNotEmpty)
                                    ? CachedNetworkImage(
                                  imageUrl: SessionController.user.profileImageUrl!,
                                  width: 45.r,
                                  height: 45.r,
                                  fit: BoxFit.cover,
                                  placeholder: (BuildContext context, String url) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (BuildContext context, String url, Object error) =>
                                      Icon(Icons.person, size: 25.r, color: Colors.grey),
                                )
                                    : Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.person, size: 25.r, color: Colors.grey[600]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Hi ${SessionController.user.fullName ?? 'User'}",
                            style: Font.montserratFont(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${SessionController.user.email ?? ''}",
                            style: Font.montserratFont(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      BlocBuilder<NotificationBloc, NotificationState>(
                        builder: (BuildContext context, NotificationState state) {
                          int unreadCount = 0;
                          if (state is NotificationsLoaded) {
                            unreadCount = state.unreadCount;
                          }

                          final IconButton icon = IconButton(
                            icon: const Icon(CupertinoIcons.bell_fill, color: MyTheme.primaryColor,),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => const NotificationScreen(),
                                ),
                              );
                            },
                          );

                          return unreadCount > 0 ?
                          badges.Badge(
                            position: badges.BadgePosition.topEnd(top: 3, end: 3),
                            badgeContent: Text(
                              unreadCount.toString(),
                              style: Font.montserratFont(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            badgeStyle: const badges.BadgeStyle(
                              badgeColor: MyTheme.primaryColor,
                              shape: badges.BadgeShape.circle,
                              padding: EdgeInsets.all(6),
                            ),
                            child: icon,
                          ) : icon;
                        },
                      ),
                      IconButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const MyRewardScreen()));
                        },
                        icon: SvgPicture.asset("assets/images/home/reward.svg",height: 20,width: 20,color: MyTheme.secondaryColor,),
                      )
                    ],
                  )

                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 30.h,),
                CardList(),
                /// Animated Action Buttons
                FadeTransition(
                  opacity: _actionButtonsAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _actionButtonsController,
                      curve: Curves.easeOutCubic,
                    )),
                    child: const BoxsesWidget(),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerAnimation extends StatefulWidget {
  final Widget child;

  const _ShimmerAnimation({required this.child});

  @override
  _ShimmerAnimationState createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const <Color>[
                Colors.transparent,
                Colors.white54,
                Colors.transparent,
              ],
              stops: <double>[
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              transform: const GradientRotation(0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}





