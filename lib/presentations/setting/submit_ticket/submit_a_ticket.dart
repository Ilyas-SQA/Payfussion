import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../logic/blocs/submit_a_ticket/submit_a_ticket_bloc.dart';
import '../../../logic/blocs/submit_a_ticket/submit_a_ticket_event.dart';
import '../../../logic/blocs/submit_a_ticket/submit_a_ticket_state.dart';

class SubmitATicket extends StatefulWidget {
  const SubmitATicket({super.key});

  @override
  State<SubmitATicket> createState() => _SubmitATicketState();
}

class _SubmitATicketState extends State<SubmitATicket> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shakeController;
  late AnimationController _successController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successRotateAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Initialize animations
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));

    _successScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _successRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    // Start entry animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      HapticFeedback.mediumImpact();

      /// Dispatch the SubmitTicketEvent to the bloc
      context.read<SubmitATicketBloc>().add(
        SubmitTicketEvent(title: title, description: description),
      );
    } else {
      /// Shake animation for validation errors
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubmitATicketBloc, SubmitATicketState>(
      listener: (context, state) {
        if (state.isSuccess) {
          _clearForm();
          _successController.forward();

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => _buildSuccessDialog(state),
          );
        } else if (state.errorMessage != null) {
          _shakeController.forward().then((_) {
            _shakeController.reset();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8.w),
                  Expanded(child: Text(state.errorMessage!)),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              SizedBox(height: 30.h),

              // Animated Back Button
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildBackButton(),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Animated Title
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                )),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildTitle(),
                ),
              ),

              SizedBox(height: 60.h),

              // Animated Form
              Expanded(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                  )),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildForm(state),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: InkWell(
              onTap: () {
                context.go('/');
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, iconValue, child) {
                        return Transform.scale(
                          scale: iconValue,
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: const Color(0xff2D9CDB),
                            size: 24.r,
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20.sp,
                        color: const Color(0xff2D9CDB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Text(
              'Create a Ticket',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24.sp,
                color: const Color(0xff2D9CDB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(SubmitATicketState state) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeOffset = _shakeAnimation.value * 10 *
            (1 - _shakeAnimation.value) *
            (2 * (_shakeAnimation.value * 10).floor() - 1);

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Title Field
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(30 * (1 - value), 0),
                        child: Opacity(
                          opacity: value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Title'),
                              SizedBox(height: 20.h),
                              _CustomTextField(
                                controller: _titleController,
                                hintText: 'Enter your subject',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Title is required.';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'Title must be at least 3 characters.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 40.h),

                  // Animated Description Field
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(30 * (1 - value), 0),
                        child: Opacity(
                          opacity: value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Description'),
                              SizedBox(height: 20.h),
                              _CustomTextField(
                                controller: _descriptionController,
                                hintText: 'Enter your description',
                                maxLines: 10,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Description is required.';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'Description must be at least 10 characters.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 30.h),

                  // Animated Submit Button
                  Center(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Opacity(
                            opacity: value,
                            child: _CustomButton(
                              text: state.isLoading ? 'Submitting...' : 'Submit',
                              onTap: state.isLoading ? () {} : _handleSubmit,
                              isLoading: state.isLoading,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessDialog(SubmitATicketState state) {
    return PopScope(
      canPop: false,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.7 + (0.3 * value),
            child: Opacity(
              opacity: value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Success Icon
                    AnimatedBuilder(
                      animation: _successController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _successScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _successRotateAnimation.value * 0.5,
                            child: Container(
                              height: 100.h,
                              width: 100.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xff2D9CDB).withOpacity(_successScaleAnimation.value),
                                    Color(0xff56CCF2).withOpacity(_successScaleAnimation.value),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xff2D9CDB).withOpacity(0.3 * _successScaleAnimation.value),
                                    blurRadius: 20 * _successScaleAnimation.value,
                                    spreadRadius: 5 * _successScaleAnimation.value,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_circle_outline,
                                size: 60.sp * _successScaleAnimation.value,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 20.h),

                    // Animated Success Text
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, textValue, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - textValue)),
                          child: Opacity(
                            opacity: textValue,
                            child: Text(
                              "Ticket Submitted Successfully!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 10.h),

                    // Animated Ticket ID
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, idValue, child) {
                        return Transform.translate(
                          offset: Offset(0, 15 * (1 - idValue)),
                          child: Opacity(
                            opacity: idValue,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Color(0xff2D9CDB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Color(0xff2D9CDB).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                "Ticket ID: ${state.ticketId}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.sp,
                                  color: Color(0xff2D9CDB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 20.h),

                    // Animated OK Button
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, buttonValue, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * buttonValue),
                          child: Opacity(
                            opacity: buttonValue,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop();
                                context.go('/');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2D9CDB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                elevation: 3,
                                shadowColor: Color(0xff2D9CDB).withOpacity(0.3),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).secondaryHeaderColor,
      ),
    );
  }
}

// ============================================================================
// CUSTOM WIDGETS
// ============================================================================
class _CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.validator,
  });

  @override
  State<_CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<_CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: AnimatedBuilder(
            animation: _focusAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _focusAnimation.value,
                child: Material(
                  elevation: _isFocused ? 8 : 5,
                  borderRadius: BorderRadius.circular(16.r),
                  shadowColor: _isFocused
                      ? Color(0xff2D9CDB).withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {
                        _isFocused = hasFocus;
                      });
                      if (hasFocus) {
                        _focusController.forward();
                      } else {
                        _focusController.reverse();
                      }
                    },
                    child: TextFormField(
                      controller: widget.controller,
                      maxLines: widget.maxLines,
                      validator: widget.validator,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: Color(0xff2D9CDB),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).secondaryHeaderColor == Colors.white
                            ? const Color(0xff525E6C)
                            : Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 15.h,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;

  const _CustomButton({
    required this.text,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<_CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<_CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pressAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pressAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              if (!widget.isLoading) {
                _pressController.forward();
              }
            },
            onTapUp: (_) {
              _pressController.reverse();
            },
            onTapCancel: () {
              _pressController.reverse();
            },
            onTap: widget.isLoading ? null : widget.onTap,
            child: Material(
              elevation: widget.isLoading ? 2 : 5,
              borderRadius: BorderRadius.circular(24.r),
              shadowColor: widget.isLoading
                  ? Colors.grey.withOpacity(0.3)
                  : Color(0xff2D9CDB).withOpacity(0.4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48.h,
                width: 200.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    colors: widget.isLoading
                        ? [Colors.grey, Colors.grey.shade400]
                        : [const Color(0xff2D9CDB), const Color(0xff56CCF2)],
                    stops: const [0.5, 1],
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: widget.isLoading
                        ? TweenAnimationBuilder<double>(
                      key: const ValueKey('loading'),
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 2 * 3.14159,
                          child: SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                        : Text(
                      key: const ValueKey('text'),
                      widget.text,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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