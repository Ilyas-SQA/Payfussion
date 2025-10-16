import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/theme.dart';
import '../../data/models/device_manager/deevice_manager_model.dart';
import '../../data/repositories/setting_repositories/device_manager/device_manager_repository.dart';
import '../../logic/blocs/setting/device_manager/device_manager_bloc.dart';
import '../../logic/blocs/setting/device_manager/device_manager_event.dart';
import '../../logic/blocs/setting/device_manager/device_manager_state.dart';


class DevicesManagementScreen extends StatefulWidget {
  const DevicesManagementScreen({super.key});

  @override
  State<DevicesManagementScreen> createState() => _DevicesManagementScreenState();
}

class _DevicesManagementScreenState extends State<DevicesManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context, DeviceModel device) {
    if (device.isActive) {
      _showSnackBar(context, "Active device cannot be logged out.", isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => FuturisticLogoutDialog(
        deviceName: device.manufacturer,
        onConfirmLogout: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          Navigator.of(dialogContext).pop();
          _showSnackBar(context, "${device.manufacturer} successfully logged out.");
          context.read<DeviceBloc>().add(FetchDevices());
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isError
        ? Theme.of(context).colorScheme.error
        : (isDark ? Colors.green.shade900.withOpacity(0.8) : Colors.green.shade50);
    final contentColor = isError
        ? Colors.white
        : (isDark ? Colors.green.shade300 : Colors.green.shade800);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.warning_amber_rounded : Icons.check_circle,
                color: contentColor, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(child: Text(message, style: TextStyle(color: contentColor))),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.only(bottom: 30.h, left: 20.w, right: 20.w),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final Color highlightColor = isDark ? Colors.grey[600]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60.h),
            _buildShimmerContainer(24.h, 80.w),
            SizedBox(height: 10.h),
            _buildShimmerContainer(24.h, 180.w),
            SizedBox(height: 40.h),
            _buildShimmerContainer(20.h, 120.w),
            SizedBox(height: 20.h),
            _buildShimmerCard(),
            SizedBox(height: 40.h),
            _buildShimmerContainer(20.h, 120.w),
            SizedBox(height: 20.h),
            ...List.generate(3, (index) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildShimmerCard(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer(double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            _buildShimmerContainer(50.h, 50.w),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildShimmerContainer(16.h, 150.w),
                  SizedBox(height: 8.h),
                  _buildShimmerContainer(12.h, 120.w),
                  SizedBox(height: 5.h),
                  _buildShimmerContainer(12.h, 80.w),
                  SizedBox(height: 5.h),
                  _buildShimmerContainer(12.h, 100.w),
                ],
              ),
            ),
            _buildShimmerContainer(30.h, 30.w),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(String title, List<DeviceModel> devices, int delay) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          )),
          SizedBox(height: 20.h),
          if (devices.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              itemBuilder: (context, index) => AnimatedCommonDeviceCard(
                leadingIconPath: _getDeviceIcon(devices[index].os ?? 'android'),
                mobileName: '${devices[index].manufacturer} ${devices[index].model}',
                lastLoginDate: _formatDate(devices[index].lastLogin),
                lastLoginTime: _formatTime(devices[index].lastLogin),
                trailingIconPath: devices[index].isActive ? 'assets/icons/setting_icons/checkmark_icon.png' : 'assets/icons/setting_icons/logout_icon.png',
                onTrailingIconTap: () => _showLogoutDialog(context, devices[index]),
                location: devices[index].location ?? 'Unknown',
                animationDelay: index * 200,
              ),
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
            )
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(Icons.devices_other, size: 80.sp, color: MyTheme.primaryColor),
            SizedBox(height: 16.h),
            Text('No other devices found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Management"),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocProvider(
        create: (BuildContext context) => DeviceBloc(DeviceRepository())..add(FetchDevices()),
        child: BlocBuilder<DeviceBloc, DeviceState>(
          builder: (BuildContext context, DeviceState state) {
            if (state is DeviceLoading) return _buildShimmerLoading();

            if (state is DeviceLoaded) {
              _fadeController.forward();
              _slideController.forward();

              final List<DeviceModel> currentDevice = state.devices.where((d) => d.isActive == true).toList();
              final List<DeviceModel> otherDevices = state.devices.where((d) => d.isActive != true).toList();

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.h),
                              if (currentDevice.isNotEmpty) ...[
                                _buildAnimatedSection('Current Device', currentDevice, 0),
                                SizedBox(height: 40.h),
                              ],
                              _buildAnimatedSection('Other Devices', otherDevices, 200),
                              SizedBox(height: 30.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (state is DeviceError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60.sp, color: Theme.of(context).colorScheme.error),
                    SizedBox(height: 16.h),
                    Text("Error: ${state.error}", textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.error)),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () => context.read<DeviceBloc>().add(FetchDevices()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  String _getDeviceIcon(String os) {
    switch (os.toLowerCase()) {
      case 'android': return 'assets/icons/setting_icons/android_icon.png';
      case 'ios': return 'assets/icons/setting_icons/ios_icon.png';
      default: return 'assets/icons/setting_icons/mobile_icon.png';
    }
  }

  String _formatDate(DateTime dateTime) =>
      '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';

  String _formatTime(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

// Updated AnimatedCommonDeviceCard with MyTheme.primaryColor
class AnimatedCommonDeviceCard extends StatefulWidget {
  final String leadingIconPath, mobileName, lastLoginDate, lastLoginTime, trailingIconPath, location;
  final VoidCallback? onTrailingIconTap;
  final int animationDelay;

  const AnimatedCommonDeviceCard({
    super.key,
    required this.leadingIconPath,
    required this.mobileName,
    required this.lastLoginDate,
    required this.lastLoginTime,
    required this.trailingIconPath,
    this.onTrailingIconTap,
    required this.location,
    this.animationDelay = 0,
  });

  @override
  State<AnimatedCommonDeviceCard> createState() => _AnimatedCommonDeviceCardState();
}

class _AnimatedCommonDeviceCardState extends State<AnimatedCommonDeviceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation, _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            height: 120.h,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(5.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Image.asset(widget.leadingIconPath, height: 50.h, width: 50.w, errorBuilder: (_, __, ___) => Icon(Icons.smartphone, size: 50.sp, color: MyTheme.primaryColor)), // Updated to MyTheme.primaryColor
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.mobileName,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                        SizedBox(height: 5.h),
                        Text('Last login: ${widget.lastLoginDate}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        SizedBox(height: 3.h),
                        Text(widget.lastLoginTime,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        SizedBox(height: 3.h),
                        Text(widget.location,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: widget.onTrailingIconTap,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Padding(
                      padding: EdgeInsets.all(8.0.sp),
                      child: Image.asset(widget.trailingIconPath, height: 30.h, width: 30.w,
                          color: widget.trailingIconPath.contains('logout')
                              ? Theme.of(context).colorScheme.error
                              : MyTheme.primaryColor, // Updated to MyTheme.primaryColor
                          errorBuilder: (_, __, ___) => Icon(
                              widget.trailingIconPath.contains('logout') ? Icons.logout : Icons.check_circle,
                              size: 30.sp, color: widget.trailingIconPath.contains('logout')
                              ? Theme.of(context).colorScheme.error
                              : MyTheme.primaryColor)), // Updated to MyTheme.primaryColor
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Updated FuturisticLogoutDialog with MyTheme.primaryColor
class FuturisticLogoutDialog extends StatefulWidget {
  final String deviceName;
  final Future<void> Function() onConfirmLogout;

  const FuturisticLogoutDialog({Key? key, required this.deviceName, required this.onConfirmLogout}) : super(key: key);

  @override
  State<FuturisticLogoutDialog> createState() => _FuturisticLogoutDialogState();
}

class _FuturisticLogoutDialogState extends State<FuturisticLogoutDialog>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _scaleController, _fadeController, _loadingController;
  late Animation<double> _scaleAnimation, _fadeAnimation, _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _loadingController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut));

    _scaleController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(25.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(color: MyTheme.primaryColor.withOpacity(0.3), blurRadius: 20.r, spreadRadius: 5.r), // Updated to MyTheme.primaryColor
              ],
            ),
            child: _isLoading ? _buildLoadingContent() : _buildDialogContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 60.sp),
        SizedBox(height: 20.h),
        Text('Confirm Logout', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 15.h),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Are you sure you want to log out from '),
              TextSpan(text: '${widget.deviceName}?', style: TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: ' This action cannot be undone.'),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDialogButton('Cancel', () => Navigator.of(context).pop(), false, Icons.cancel_outlined),
            _buildDialogButton('Logout', () async {
              setState(() => _isLoading = true);
              _loadingController.repeat();
              await widget.onConfirmLogout();
            }, true, Icons.logout_rounded, Theme.of(context).colorScheme.error),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 40.h),
        AnimatedBuilder(
          animation: _loadingAnimation,
          builder: (context, child) => Transform.rotate(
            angle: _loadingAnimation.value * 2 * 3.14159,
            child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MyTheme.primaryColor)), // Updated to MyTheme.primaryColor
          ),
        ),
        SizedBox(height: 24.h),
        Text("Logging out ${widget.deviceName}...", style: Theme.of(context).textTheme.bodyLarge),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildDialogButton(String text, VoidCallback onPressed, bool isPrimary, IconData icon, [Color? color]) {
    final buttonColor = color ?? (isPrimary ? MyTheme.primaryColor : Theme.of(context).colorScheme.surfaceVariant); // Updated to MyTheme.primaryColor
    final textColor = isPrimary ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant;

    return ElevatedButton.icon(
      icon: Icon(icon, size: 18.sp, color: textColor),
      label: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
      onPressed: onPressed,
    );
  }
}