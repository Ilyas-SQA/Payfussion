import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2.0,
      color: colors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  PermissionUtils.getPermissionIcon(permission),
                  size: 28,
                  color: MyTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(PermissionUtils.getPermissionTitle(permission),
                          style: AppStyles.cardTitleStyle(context)),
                      const SizedBox(height: 4),
                      Text(
                        PermissionUtils.getPermissionDescription(permission),
                        style: AppStyles.bodyTextStyle(
                          context,
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
              children: [
                Text(
                  isGranted ? 'Currently allowed' : 'Currently denied',
                  style: AppStyles.bodyTextStyle(context).copyWith(
                    color: isGranted ? colors.success : colors.error,
                    fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
