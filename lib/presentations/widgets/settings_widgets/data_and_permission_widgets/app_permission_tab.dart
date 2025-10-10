import 'package:flutter/material.dart';
import 'package:payfussion/presentations/widgets/settings_widgets/data_and_permission_widgets/permission_card.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/setting_utils/data_and_permission_utils/app_colors_utils.dart';
import '../../../../core/utils/setting_utils/data_and_permission_utils/app_styles.dart';
import '../../../../core/utils/setting_utils/data_and_permission_utils/permission_utils.dart';
import 'bullet_points.dart';
import 'feature_card.dart';

class AppPermissionsTab extends StatelessWidget {
  final AppColors colors;
  final Map<Permission, PermissionStatus> permissionStatus;
  final Function(Permission) onPermissionRequested;

  const AppPermissionsTab({
    super.key,
    required this.colors,
    required this.permissionStatus,
    required this.onPermissionRequested,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Permissions',
            style: AppStyles.sectionTitleStyle(context, color: Theme.of(context).secondaryHeaderColor,),
          ),
          const SizedBox(height: 8),
          Text(
            'Control which features and device capabilities PayFusion can access.',
            style: AppStyles.bodyTextStyle(context),
          ),
          const SizedBox(height: 24),

          // Permission cards
          ...PermissionUtils.allPermissions.map((permission) =>
              Column(
                children: [
                  PermissionCard(
                    permission: permission,
                    status: permissionStatus[permission],
                    colors: colors,
                    onRequest: onPermissionRequested,
                  ),
                  const SizedBox(height: 16),
                ],
              )
          ),

          // Permission information
          FeatureCard(
            icon: Icons.info_outline,
            iconColor: colors.warning,
            title: 'Why We Need Permissions',
            colors: colors,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BulletPoint(
                  'PayFusion only requests permissions essential to its functionality.',
                ),
                BulletPoint(
                  'You can deny or revoke permissions at any time, but some features may be limited.',
                ),
                BulletPoint(
                  'We never access your device features for purposes beyond those stated in our privacy policy.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}