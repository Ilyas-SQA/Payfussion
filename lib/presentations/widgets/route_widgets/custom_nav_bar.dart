import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payfussion/data/models/home_modals/nav_bar_items.dart';

import '../../../core/constants/fonts.dart';
import '../../../core/theme/theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: PhysicalModel(
        elevation: 40,
        color: theme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          topRight: Radius.circular(10.r),
        ),
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black.withOpacity(0.25),
        child: Container(
          height: 90.h,
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
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navBarItems.map((NavBarItems item) {
              final bool isSelected = navBarItems.indexOf(item) == currentIndex;
              return GestureDetector(
                onTap: () => onTap(navBarItems.indexOf(item)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      item.icon,
                      width: 25,
                      height: 25,
                      color: isSelected ? MyTheme.primaryColor : Colors.grey,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      item.title,
                      style: Font.montserratFont(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: isSelected ? MyTheme.primaryColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
