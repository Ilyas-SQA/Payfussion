import 'package:flutter/material.dart';
import 'package:payfussion/presentations/splash_screen/splash_service.dart';
import 'package:payfussion/presentations/widgets/background_theme.dart';
import '../../core/circular_indicator.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/image_url.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final SplashServices splashServices = SplashServices();

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();

    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    /// Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));

    _logoRotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Text animations
    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));


    // Start animations sequence
    _startAnimations();
  }

  void _startAnimations() async {
    // Start background fade immediately
    _fadeController.forward();

    // Wait a bit, then start logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Wait for logo animation to be halfway, then start text animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Wait for all animations to complete, then check authentication
    await Future.delayed(const Duration(milliseconds: 1500));
    splashServices.checkAuthentication(context);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable?>[
          _logoController,
          _textController,
          _fadeController,
        ]),
        builder: (BuildContext context, Widget? child) {
          return Stack(
            children: <Widget>[
              AnimatedBackground(
                animationController: _backgroundAnimationController,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Animated Logo
                    Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotationAnimation.value,
                        child: Opacity(
                          opacity: _logoOpacityAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.asset(
                              TImageUrl.iconLogo,
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Animated Text
                    Transform.translate(
                      offset: Offset(0, _textSlideAnimation.value),
                      child: Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: Text(
                          'PayFussion',
                          style: Font.montserratFont(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    // Awesome Loader (using SpinKit from flutter_spinkit)
                    const SizedBox(height: 40),
                    Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: CircularIndicator.circular,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
