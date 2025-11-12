import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/data/models/user/user_model.dart';
import 'package:payfussion/logic/blocs/setting/user_profile/profile_state.dart';
import '../../../core/circular_indicator.dart';
import '../../../core/constants/fonts.dart';
import '../../../logic/blocs/setting/user_profile/profile_bloc.dart';
import '../../../logic/blocs/setting/user_profile/profile_event.dart';
import '../../../services/session_manager_service.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../../widgets/background_theme.dart';
import '../../widgets/settings_widgets/profiles_widgets/editable_card.dart';

class ProfileHomeScreen extends StatefulWidget {
  const ProfileHomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileHomeScreenState createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends State<ProfileHomeScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late String _userName,
      _userEmail,
      _userFirstName,
      _userLastName,
      _phoneNumber;

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _profileController;
  late AnimationController _contentController;
  late AnimationController _buttonsController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _profileScale;
  late Animation<Offset> _profileSlide;
  late Animation<double> _contentFade;
  late Animation<double> _buttonsFade;
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _initUserData();
    _initAnimations();
    _startAnimations();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _profileController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    _profileScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _profileController, curve: Curves.elasticOut),
    );

    _profileSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _profileController, curve: Curves.easeOut));

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _profileController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _buttonsController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _profileController.dispose();
    _contentController.dispose();
    _buttonsController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _initUserData() {
    final UserModel user = SessionController.user;
    _userName = user.fullName ?? '';
    _userEmail = user.email ?? '';
    _userFirstName = user.firstName ?? '';
    _userLastName = user.lastName ?? '';
    _phoneNumber = user.phoneNumber ?? '';
  }

  Future<void> _pickAndUploadProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<ProfileBloc>().add(UpdateProfileImage(profileImage: image));
    }
  }



  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (BuildContext context, ProfileState state) {
        if (state is ProfileLoading) {
          _showLoadingDialog();
          return;
        }

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (state is ProfileSucess) {
          _handleProfileSuccess();
        } else if (state is LogoutSuccess) {
          context.go(RouteNames.signIn);
        } else if (state is ProfileFailure) {
          context.showErrorDialog(state.message);
        }
      },
      builder: (BuildContext context, ProfileState state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text("Profile"),
            elevation: 0,
          ),
          body: Stack(
            children: <Widget>[
              AnimatedBackground(
                animationController: _backgroundAnimationController,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 15.h),

                      // Animated profile image
                      SlideTransition(
                        position: _profileSlide,
                        child: ScaleTransition(
                          scale: _profileScale,
                          child: _buildProfileImage(),
                        ),
                      ),
                      SizedBox(height: 15.h),

                      // Animated username
                      ScaleTransition(
                        scale: _profileScale,
                        child: FadeTransition(
                          opacity: _profileController,
                          child: _buildUserName(),
                        ),
                      ),
                      SizedBox(height: 15.h),

                      // Animated editable cards
                      FadeTransition(
                        opacity: _contentFade,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_contentController),
                          child: _buildEditableCards(),
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Animated buttons
                      FadeTransition(
                        opacity: _buttonsFade,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(_buttonsController),
                          child: Column(
                            children: <Widget>[
                              _buildChangePasswordButton(),
                              SizedBox(height: 20.h),
                              _buildLogoutButton(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          elevation: 2, // Reduced from 10 to 4
          child: CircleAvatar(
            radius: 45.r,
            backgroundColor: Colors.grey,
            child: _userProfileImage(),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: CircleAvatar(
              radius: 15.r,
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: Icon(
                    Icons.edit,
                    size: 15.r,
                    color: MyTheme.primaryColor
                ),
                onPressed: _pickAndUploadProfileImage,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _userProfileImage() {
    final String? profileImageUrl = SessionController.user.profileImageUrl;
    return profileImageUrl != null && profileImageUrl.isNotEmpty ? ClipOval(
      child: CachedNetworkImage(
        imageUrl: profileImageUrl,
        width: 100.w,
        height: 100.h,
        fit: BoxFit.cover,
        placeholder: (_, __) => const CircularProgressIndicator(),
        errorWidget: (_, __, ___) =>
            Icon(Icons.person, size: 30.r, color: Colors.white),
      ),
    )
        : Icon(Icons.person, size: 30.r, color: Colors.white);
  }

  Widget _buildUserName() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        _userName,
        style: Font.montserratFont(
          fontSize: 20.sp,
          color: Theme.of(context).secondaryHeaderColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEditableCards() {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 200),
          childAnimationBuilder: (Widget widget) => SlideAnimation(
            verticalOffset: 20.0,
            child: FadeInAnimation(child: widget),
          ),
          children: <Widget>[
            // Editable First Name
            EditableCard(
              title: 'First Name',
              initialValue: _userFirstName,
              leadingIcon: Icons.person_outline,
              keyboardType: TextInputType.text,
              onSave: (String newValue) async => _updateFirstName(newValue),
            ),
            SizedBox(height: 8.h),

            // Editable Last Name
            EditableCard(
              title: 'Last Name',
              initialValue: _userLastName,
              leadingIcon: Icons.person_outline,
              keyboardType: TextInputType.text,
              onSave: (String newValue) async => _updateLastName(newValue),
            ),
            SizedBox(height: 8.h),

            // Read-only Phone Number
            _buildReadOnlyCard(
              title: 'Phone Number',
              value: _phoneNumber,
              icon: Icons.phone_outlined,
            ),
            SizedBox(height: 8.h),

            // Read-only Email
            _buildReadOnlyCard(
              title: 'Email',
              value: _userEmail,
              icon: Icons.email_outlined,
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  // Read-only card widget for non-editable fields
  Widget _buildReadOnlyCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 24.r,
            color: Colors.grey,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Font.montserratFont(
                    fontSize: 12.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value.isNotEmpty ? value : 'Not provided',
                  style: Font.montserratFont(
                    fontSize: 16.sp,
                    color: Theme.of(context).secondaryHeaderColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline,
            size: 20.r,
            color: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () => context.push(RouteNames.changePass),
        child: Container(
          width: 362.w,
          height: 63.h,
          decoration: BoxDecoration(
            color: MyTheme.primaryColor,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(Icons.lock_outline, size: 24.r, color: Colors.white),
              Text(
                'Change Password',
                style: Font.montserratFont(
                  fontSize: 18.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 24.r,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () {
          context.read<ProfileBloc>().add(Logout());
        },
        child: Container(
          width: 362.w,
          height: 63.h,
          decoration: BoxDecoration(
            color: const Color(0xffDB2D30),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Logout',
                style: Font.montserratFont(
                  fontSize: 18.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Center(child: CircularIndicator.circular),
      ),
    );
  }

  void _handleProfileSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    _initUserData();
  }

  void _updateFirstName(String newValue) {
    context.read<ProfileBloc>().add(UpdateFirstName(firstName: newValue));
  }

  void _updateLastName(String newValue) {
    context.read<ProfileBloc>().add(UpdateLastName(lastName: newValue));
  }
}