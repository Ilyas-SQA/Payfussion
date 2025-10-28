import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:payfussion/presentations/my_reward/my_reward_screen.dart';

import '../../core/constants/fonts.dart';
import '../../core/constants/routes_name.dart';
import '../../core/theme/theme.dart';
import '../../logic/blocs/notification/notification_bloc.dart';
import '../../logic/blocs/notification/notification_state.dart';
import '../../services/session_manager_service.dart';
import '../notification/notification_screen.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xff666666);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // Profile Avatar
          GestureDetector(
            onTap: () => context.push(RouteNames.profile),
            child: Hero(
              tag: 'profile_avatar',
              child: CircleAvatar(
                radius: 20.r,
                backgroundColor: Colors.grey,
                child: (SessionController.user.profileImageUrl != null &&
                    SessionController.user.profileImageUrl!.isNotEmpty)
                    ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: SessionController.user.profileImageUrl!,
                    width: 40.r,
                    height: 40.r,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(strokeWidth: 2),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.person),
                  ),
                )
                    : Icon(Icons.person, size: 30.r, color: Colors.white),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Name and Email Column
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(RouteNames.profile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SessionController.user.fullName ?? 'User',
                    style: Font.montserratFont(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    SessionController.user.email ?? '',
                    style: Font.montserratFont(
                      fontSize: 10.sp,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Icons: Notification & Reward
          Row(
            children: [
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
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
                          builder: (context) => const NotificationScreen(),
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
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const MyRewardScreen()));
                },
                child: SvgPicture.asset(
                  "assets/images/home/reward.svg",
                  height: 22.r,
                  width: 22.r,
                  color: MyTheme.primaryColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
