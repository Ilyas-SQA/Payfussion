import 'package:flutter/material.dart';
import 'package:payfussion/presentations/widgets/settings_widgets/data_and_permission_widgets/permission_card.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/fonts.dart';
import '../../../../core/utils/setting_utils/data_and_permission_utils/app_colors_utils.dart';
import '../../../../core/utils/setting_utils/data_and_permission_utils/permission_utils.dart';
import '../../background_theme.dart';
import 'bullet_points.dart';
import 'feature_card.dart';

class AppPermissionsTab extends StatefulWidget {
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
  State<AppPermissionsTab> createState() => _AppPermissionsTabState();
}

class _AppPermissionsTabState extends State<AppPermissionsTab> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedBackground(
          animationController: _backgroundAnimationController,
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'App Permissions',
                style: Font.montserratFont(fontSize: 18,fontWeight: FontWeight.bold,),
              ),
              const SizedBox(height: 8),
              Text(
                'Control which features and device capabilities PayFusion can access.',
                style: Font.montserratFont(fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Permission cards
              ...PermissionUtils.allPermissions.map((Permission permission) =>
                  Column(
                    children: <Widget>[
                      PermissionCard(
                        permission: permission,
                        status: widget.permissionStatus[permission],
                        colors: widget.colors,
                        onRequest: widget.onPermissionRequested,
                      ),
                      const SizedBox(height: 16),
                    ],
                  )
              ),

              // Permission information
              FeatureCard(
                icon: Icons.info_outline,
                iconColor: widget.colors.warning,
                title: 'Why We Need Permissions',
                colors: widget.colors,
                content: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
        ),
      ],
    );
  }
}