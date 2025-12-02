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

  String _getStatusText() {
    if (status == null) return 'Unknown';

    if (status!.isGranted) {
      return 'Currently allowed';
    } else if (status!.isDenied) {
      return 'Currently denied';
    } else if (status!.isPermanentlyDenied) {
      return 'Permanently denied';
    } else if (status!.isRestricted) {
      return 'Restricted';
    } else if (status!.isLimited) {
      return 'Limited access';
    } else {
      return 'Not determined';
    }
  }

  Color _getStatusColor() {
    if (status == null) return colors.textSecondary;

    if (status!.isGranted) {
      return colors.success;
    } else if (status!.isPermanentlyDenied) {
      return colors.error;
    } else {
      return colors.warning;
    }
  }

  String _getButtonText() {
    if (status == null) return 'Request';

    if (status!.isGranted) {
      return 'Manage';
    } else if (status!.isPermanentlyDenied) {
      return 'Settings';
    } else {
      return 'Allow';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isGranted = status?.isGranted ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.withOpacity(0.2)
                : Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MyTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  PermissionUtils.getPermissionIcon(permission),
                  size: 24,
                  color: MyTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      PermissionUtils.getPermissionTitle(permission),
                      style: AppStyles.cardTitleStyle(context),
                    ),
                    const SizedBox(height: 6),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(),
                      style: AppStyles.bodyTextStyle(context).copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (status?.isGranted ?? false) {
                      await openAppSettings();
                    } else if (status?.isPermanentlyDenied ?? false) {
                      await openAppSettings();
                    } else {
                      onRequest(permission);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGranted
                        ? colors.primary.withOpacity(0.8)
                        : MyTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    _getButtonText(),
                    style: AppStyles.buttonTextStyle(context).copyWith(
                      fontSize: 12,
                    ),
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