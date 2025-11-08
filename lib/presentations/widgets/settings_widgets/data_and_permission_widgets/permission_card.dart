import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/fonts.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/setting_utils/data_and_permission_utils/app_colors_utils.dart';
import '../../../../core/utils/setting_utils/data_and_permission_utils/app_styles.dart';
import '../../../../core/utils/setting_utils/data_and_permission_utils/permission_utils.dart';

class PermissionCard extends StatelessWidget {
  final Permission permission;
  final PermissionStatus? status;
  final AppColors colors;
  final Function(Permission) onRequest;

  const PermissionCard({
    super.key,
    required this.permission,
    required this.status,
    required this.colors,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGranted = status?.isGranted ?? false;

    return Container(
      padding: const EdgeInsets.all(10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                PermissionUtils.getPermissionIcon(permission),
                size: 28,
                color: MyTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(PermissionUtils.getPermissionTitle(permission), style: AppStyles.cardTitleStyle(context)),
                    const SizedBox(height: 4),
                    Text(
                      PermissionUtils.getPermissionDescription(permission),
                      style: Font.montserratFont(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                isGranted ? 'Currently allowed' : 'Currently denied',
                style: AppStyles.bodyTextStyle(context).copyWith(
                  color: isGranted ? colors.success : colors.error,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (isGranted) {
                    openAppSettings();
                  } else {
                    onRequest(permission);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGranted ? colors.primary : MyTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  isGranted ? 'Manage' : 'Allow',
                  style: AppStyles.buttonTextStyle(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
