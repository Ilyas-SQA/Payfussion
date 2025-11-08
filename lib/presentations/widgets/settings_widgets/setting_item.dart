import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../logic/blocs/currency/currency_bloc.dart';
import '../../../logic/blocs/currency/currency_state.dart';
import '../../../logic/blocs/currency/currency_event.dart';

class SettingTile extends StatefulWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingBuilder,
    this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Widget Function(BuildContext ctx)? trailingBuilder;
  final VoidCallback? onTap;

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: MyTheme.primaryColor,
      end: MyTheme.primaryColor,
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

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final Widget? trailing = widget.trailingBuilder?.call(context);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: _animationController.isAnimating
                    ? Colors.grey.withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 42.w,
                        height: 42.h,
                        padding: EdgeInsets.all(6.0.r),
                        decoration: BoxDecoration(
                          color: _colorAnimation.value ?? MyTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: _animationController.isAnimating
                              ? <BoxShadow>[
                            BoxShadow(
                              color: MyTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                              : <BoxShadow>[],
                        ),
                        child: Center(
                          child: AnimatedScale(
                            scale: _animationController.isAnimating ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: SvgPicture.asset(
                              widget.icon,
                              fit: BoxFit.contain,
                              height: 22.h,
                              width: 22.w,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      12.horizontalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: _animationController.isAnimating
                                  ? MyTheme.primaryColor
                                  : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                            ),
                            child: Text(widget.title),
                          ),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12.sp,
                              color: _animationController.isAnimating
                                  ? Colors.grey[600]
                                  : Colors.grey,
                            ),
                            child: Text(widget.subtitle),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (trailing != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Flexible(child: trailing),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget switchTrailing({
  required bool value,
  required ValueChanged<bool> onChanged,
}) => TweenAnimationBuilder<double>(
  duration: const Duration(milliseconds: 300),
  tween: Tween<double>(begin: 0, end: value ? 1 : 0),
  builder: (BuildContext context, double animValue, Widget? child) {
    return SizedBox(
      width: 45.w,
      height: 25.h,
      child: Transform.scale(
        scale: 0.9 + (animValue * 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Color.lerp(
              MyTheme.primaryColor.withOpacity(.4),
              MyTheme.primaryColor.withOpacity(.6),
              animValue,
            ),
            inactiveThumbColor: Color.lerp(
              MyTheme.primaryColor.withOpacity(.7),
              MyTheme.primaryColor,
              1 - animValue,
            ),
            inactiveTrackColor: MyTheme.primaryColor.withOpacity(.6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

          ),
        ),
      ),
    );
  },
);

Widget currencyPicker({required BuildContext context}) =>
    BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (BuildContext context, CurrencyState state) {
        String currencyName = 'USD';
        if (state is CurrencyInitialState && state.currency.isNotEmpty) {
          currencyName = state.currency;
        } else if (state is CurrencyUpdatedState && state.currency.isNotEmpty) {
          currencyName = state.currency;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: InkWell(
            onTap: () {

              showCurrencyPicker(
                context: context,
                showFlag: true,
                showCurrencyName: true,
                showCurrencyCode: true,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                onSelect: (Currency currency) {
                  context.read<CurrencyBloc>().add(
                    SetCurrencyEvent(currency.code),
                  );
                },
              );
            },
            borderRadius: BorderRadius.circular(8.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: MyTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.3, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      currencyName,
                      key: ValueKey(currencyName),
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (BuildContext context, double value, Widget? child) {
                      return Transform.rotate(
                        angle: value * 0.1, // Subtle rotation animation
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: 24.sp,
                            color: MyTheme.primaryColor,
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
    );