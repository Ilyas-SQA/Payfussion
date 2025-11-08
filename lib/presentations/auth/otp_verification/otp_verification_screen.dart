import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/logic/blocs/auth/auth_bloc.dart';
import 'package:payfussion/services/session_manager_service.dart';

import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? phoneNumber; // Optional parameter for phone number

  const OtpVerificationScreen({
    super.key,
    this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String otp = "";
  bool isButtonEnabled = false;
  String? verificationId;

  int _start = 30;
  Timer? _timer;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTimer();
    _sendOtpOnInit();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  void _sendOtpOnInit() {
    // Get phone number from widget parameter or session
    final String phoneNumber = widget.phoneNumber ??
        SessionController.user.phoneNumber?.toString() ?? '';

    if (phoneNumber.isNotEmpty) {
      context.read<AuthBloc>().add(SendOtpEvent(phoneNumber: phoneNumber));
    }
  }

  void _startTimer() {
    _start = 30;
    _timer?.cancel(); // Cancel existing timer if any
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        _timer?.cancel();
        // Timer complete ho gaya, ab user manually resend kar sakta hai
      } else {
        if (mounted) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  void _onOtpChanged() {
    otp = _controllers.map((TextEditingController c) => c.text).join();
    setState(() {
      isButtonEnabled = otp.length == 6;
    });

    // Auto verify when all 6 digits are entered
    if (otp.length == 6 && verificationId != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _verifyOtp();
      });
    }
  }

  void _resendOtp() {
    if (_start == 0) {
      _startTimer(); // Restart timer
      _clearOtpFields();

      final String phoneNumber = widget.phoneNumber ??
          SessionController.user.phoneNumber?.toString() ?? '';

      if (phoneNumber.isNotEmpty) {
        context.read<AuthBloc>().add(ResendOtpEvent(phoneNumber: phoneNumber));
      }
    }
  }

  void _verifyOtp() {
    if (isButtonEnabled && verificationId != null) {
      // Add haptic feedback
      HapticFeedback.lightImpact();

      context.read<AuthBloc>().add(
        VerifyOtpEvent(otp: otp, verificationId: verificationId!),
      );
    }
  }

  void _clearOtpFields() {
    for (TextEditingController controller in _controllers) {
      controller.clear();
    }
    setState(() {
      otp = "";
      isButtonEnabled = false;
    });
    // Focus on first field after clearing
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    for (TextEditingController c in _controllers) {
      c.dispose();
    }
    for (FocusNode f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Widget _buildOtpBox(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? Colors.blue
              : _focusNodes[index].hasFocus
              ? Colors.blue.shade300
              : Colors.grey.shade300,
          width: _controllers[index].text.isNotEmpty || _focusNodes[index].hasFocus
              ? 2.5
              : 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: _controllers[index].text.isNotEmpty
            ? Colors.blue.shade50
            : Colors.white,
        boxShadow: _focusNodes[index].hasFocus
            ? <BoxShadow>[
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : <BoxShadow>[],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _controllers[index].text.isNotEmpty
              ? Colors.blue.shade800
              : Colors.grey.shade600,
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (String value) {
          if (value.isNotEmpty) {
            // Move to next field
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Last field, remove focus
              _focusNodes[index].unfocus();
            }
          } else {
            // Move to previous field on backspace
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
          _onOtpChanged();
        },
        onTap: () {
          // Select all text when tapped
          _controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[index].text.length),
          );
        },
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle,
        size: 50,
        color: Colors.green,
      ),
    );
  }

  Widget _buildPhoneIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.phone_android,
        size: 45,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String phoneNumber = widget.phoneNumber ??
        SessionController.user.phoneNumber?.toString() ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "OTP Verification",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state is OtpSent) {
            verificationId = state.verificationId;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: <Widget>[
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is OtpVerified) {
            // Cancel timer when OTP is verified
            _timer?.cancel();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: <Widget>[
                    const Icon(Icons.verified, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 1),
              ),
            );

            // Navigate to home screen immediately after showing success message
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                // Navigate to home screen - change '/homeScreen' to your actual route
                context.pushReplacement('/homeScreen');
              }
            });
          } else if (state is OtpError) {
            _clearOtpFields();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: <Widget>[
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.error,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (BuildContext context, AuthState state) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 30),

                      // Phone Icon with Animation
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: state is OtpVerified
                            ? _buildSuccessAnimation()
                            : _buildPhoneIcon(),
                      ),

                      const SizedBox(height: 40),

                      // Title
                      Text(
                        state is OtpVerified
                            ? "Verification Successful!"
                            : "Verify your phone number",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: state is OtpVerified
                              ? Colors.green.shade700
                              : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        state is OtpVerified
                            ? "Redirecting to home screen..."
                            : "Enter the 6-digit code sent to\n$phoneNumber",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // OTP Input Fields
                      if (state is! OtpVerified)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (int index) => _buildOtpBox(index)),
                        ),

                      const SizedBox(height: 50),

                      // Verify Button
                      if (state is! OtpVerified)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (state is OtpLoading) ? null :
                            (isButtonEnabled ? _verifyOtp : null),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isButtonEnabled
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade300,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: isButtonEnabled ? 4 : 0,
                              shadowColor: Colors.blue.withOpacity(0.3),
                            ),
                            child: (state is OtpLoading)
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text(
                              "Verify OTP",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),

                      // Manual Resend Section
                      if (state is! OtpVerified)
                        Column(
                          children: <Widget>[
                            Text(
                              "Didn't receive the code?",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _start > 0
                                ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _start <= 10
                                    ? Colors.orange.shade50
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _start <= 10
                                      ? Colors.orange.shade200
                                      : Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.timer,
                                    size: 16,
                                    color: _start <= 10
                                        ? Colors.orange.shade700
                                        : Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Resend in $_start seconds",
                                    style: TextStyle(
                                      color: _start <= 10
                                          ? Colors.orange.shade700
                                          : Colors.blue.shade700,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : TextButton.icon(
                              onPressed: (state is OtpLoading) ? null : _resendOtp,
                              icon: Icon(
                                Icons.refresh,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                              label: Text(
                                "Send Again",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                backgroundColor: Colors.blue.shade50,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}