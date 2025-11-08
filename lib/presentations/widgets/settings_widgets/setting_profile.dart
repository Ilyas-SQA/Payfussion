import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/data/models/user/user_model.dart';

import '../../../services/session_manager_service.dart';

class SettingProfile extends StatelessWidget {
  final VoidCallback onTap;

  const SettingProfile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final UserModel user = SessionController.user;

    return Container(
      height: 94.h,
      width: 380.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
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
        onTap: onTap,
        child: Row(
          children: <Widget>[
            // Profile image
            CircleAvatar(
              radius: 28.r,
              backgroundColor: Colors.grey,
              child:
                  user.profileImageUrl != null &&
                      user.profileImageUrl!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.profileImageUrl!,
                        width: 80.r,
                        height: 80.r,
                        fit: BoxFit.cover,
                        placeholder: (BuildContext context, String url) =>
                            const CircularProgressIndicator(),
                        errorWidget:
                            (
                              BuildContext context,
                              String url,
                              Object error,
                            ) => Icon(
                              Icons.person,
                              size: 30.r,
                              color: Colors.white,
                            ),
                      ),
                    )
                  : Icon(Icons.person, size: 40.r, color: Colors.white),
            ),
            10.horizontalSpace,
            // Profile name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.fullName ?? 'Guest User',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16.sp,
                    color: theme.secondaryHeaderColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email ?? 'Not signed in',
                  style: TextStyle(
                    color: theme.secondaryHeaderColor,
                    fontFamily: 'Roboto',
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  user.phoneNumber ?? '',
                  style: TextStyle(
                    color: theme.secondaryHeaderColor,
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            // Arrow icon
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: onTap,
                icon: Icon(
                  Icons.chevron_right,
                  size: 50.sp,
                  color: MyTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
