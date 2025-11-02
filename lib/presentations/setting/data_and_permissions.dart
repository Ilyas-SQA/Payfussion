import 'package:flutter/material.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/fonts.dart';
import '../../core/utils/setting_utils/data_and_permission_utils/app_colors_utils.dart';
import '../../core/utils/setting_utils/data_and_permission_utils/permission_utils.dart';
import '../widgets/settings_widgets/data_and_permission_widgets/app_permission_tab.dart';
import '../widgets/settings_widgets/data_and_permission_widgets/data_management_tab.dart';
import '../widgets/settings_widgets/data_and_permission_widgets/privacy_setting_tab.dart';

class DataAndPermissionsScreen extends StatefulWidget {
  const DataAndPermissionsScreen({super.key});

  @override
  State<DataAndPermissionsScreen> createState() => _DataAndPermissionsScreenState();
}

class _DataAndPermissionsScreenState extends State<DataAndPermissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<Permission, PermissionStatus> _permissionStatus = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initPermissions();
    // Listen for app resume to refresh permissions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AppLifecycleState state =
          WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
      if (state == AppLifecycleState.resumed) {
        _refreshPermissions();
      }
    });
  }

  Future<void> _initPermissions() async {
    final permissions = PermissionUtils.allPermissions;
    await _updatePermissionStatus(permissions);
  }

  Future<void> _refreshPermissions() async {
    await _updatePermissionStatus(PermissionUtils.allPermissions);
  }

  Future<void> _updatePermissionStatus(List<Permission> permissions) async {
    final Map<Permission, PermissionStatus> statuses = {};
    for (var permission in permissions) {
      statuses[permission] = await permission.status;
    }

    if (mounted) {
      setState(() {
        _permissionStatus = statuses;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors for proper dark/light mode support
    final AppColors colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Permissions'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).scaffoldBackgroundColor,
          labelColor: Theme.of(context).secondaryHeaderColor,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          padding: EdgeInsets.all(10),
          indicator: BoxDecoration(
            color: MyTheme.primaryColor,
            borderRadius: BorderRadius.circular(10)
          ),
          dividerColor: Theme.of(context).scaffoldBackgroundColor,
          tabAlignment: TabAlignment.center,
          labelStyle: Font.montserratFont(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          tabs: <Widget>[
            const Tab(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text('Data Management'),
              ),
            ),
            const Tab(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text('App Permissions'),
              ),
            ),
            const Tab(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text('Privacy Settings'),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DataManagementTab(colors: colors),
          AppPermissionsTab(
            colors: colors,
            permissionStatus: _permissionStatus,
            onPermissionRequested: _handlePermissionRequest,
          ),
          PrivacySettingsTab(colors: colors),
        ],
      ),
    );
  }

  Future<void> _handlePermissionRequest(Permission permission) async {
    final PermissionStatus status = await permission.request();
    await _refreshPermissions();
  }
}
