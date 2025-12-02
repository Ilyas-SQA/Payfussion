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

  const AppPermissionsTab({
    super.key,
    required this.colors,
  });

  @override
  State<AppPermissionsTab> createState() => _AppPermissionsTabState();
}

class _AppPermissionsTabState extends State<AppPermissionsTab> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  Map<Permission, PermissionStatus> _permissionStatuses = <Permission, PermissionStatus>{};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _loadPermissionStatuses();
  }

  Future<void> _loadPermissionStatuses() async {
    setState(() => _isLoading = true);

    final Map<Permission, PermissionStatus> statuses = <Permission, PermissionStatus>{};

    for (final Permission permission in PermissionUtils.allPermissions) {
      statuses[permission] = await permission.status;
    }

    if (mounted) {
      setState(() {
        _permissionStatuses = statuses;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final PermissionStatus status = await permission.request();

    if (mounted) {
      setState(() {
        _permissionStatuses[permission] = status;
      });

      // Show result message
      if (status.isGranted) {
        _showSnackBar('${PermissionUtils.getPermissionTitle(permission)} permission granted', Colors.green);
      } else if (status.isDenied) {
        _showSnackBar('${PermissionUtils.getPermissionTitle(permission)} permission denied', Colors.orange);
      } else if (status.isPermanentlyDenied) {
        _showSnackBar(
          '${PermissionUtils.getPermissionTitle(permission)} permission permanently denied. Please enable it from settings.',
          Colors.red,
        );
        // Optionally open app settings after a delay
        await Future<void>.delayed(const Duration(seconds: 2));
        await openAppSettings();
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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
        RefreshIndicator(
          onRefresh: _loadPermissionStatuses,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'App Permissions',
                  style: Font.montserratFont(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Control which features and device capabilities PayFusion can access.',
                  style: Font.montserratFont(fontSize: 12),
                ),
                const SizedBox(height: 24),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                // Permission cards
                  ...PermissionUtils.allPermissions.map(
                        (Permission permission) => Column(
                      children: <Widget>[
                        PermissionCard(
                          permission: permission,
                          status: _permissionStatuses[permission],
                          colors: widget.colors,
                          onRequest: _requestPermission,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}