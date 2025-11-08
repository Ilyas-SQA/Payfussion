// lib/presentations/widgets/quick_access/quick_access_avatar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickAccessAvatar extends StatelessWidget {
  final String name;
  final String imagePath;
  final VoidCallback? onTap;

  const QuickAccessAvatar({
    super.key,
    required this.name,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 56.h,
              width: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: Image.network(
                  imagePath.isNotEmpty ?
                    imagePath :
                  "https://i.pinimg.com/1200x/cd/4b/d9/cd4bd9b0ea2807611ba3a67c331bff0b.jpg",
                    fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              name,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.primaryColor != Colors.white
                    ? const Color(0xffffffff)
                    : const Color(0xff666666),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
