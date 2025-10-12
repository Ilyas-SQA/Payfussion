import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payfussion/presentations/home/send_money/bank_widget.dart';
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../data/repositories/recipient/recipient_repository.dart';
import '../../../logic/blocs/recipient/recipient_bloc.dart';
import '../../../logic/blocs/recipient/recipient_event.dart';
import '../../../logic/blocs/recipient/recipient_state.dart';

class RecipientStrings {
  static const String addRecipient = 'Add Recipient';
  static const String addNewRecipient = 'Add New Recipient';
  static const String recipientDetails = 'Enter the details of the person you want to send money to.';
  static const String fullName = 'Full Name';
  static const String enterFullName = 'Enter recipient full name';
  static const String bankName = 'Bank';
  static const String selectBank = 'Select a bank';
  static const String accountNumber = 'Account Number';
  static const String enterAccountNumber = 'Enter account number';
  static const String addButtonText = 'Add Recipient';
  static const String saveAndAddAnother = 'Save & Add Another';
  static const String successTitle = 'Recipient Added Successfully!';
  static const String successMessage = 'You can now send money to this recipient';
  static const String sendMoneyTo = 'Send Money to';
  static const String backToRecipients = 'Back to Recipients';
  static const String addPhoto = 'Add Photo';
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';
  static const String cancel = 'Cancel';
}

class AddRecipientScreen extends StatelessWidget {
  const AddRecipientScreen({super.key});

  String _userId() => FirebaseAuth.instance.currentUser?.uid ?? 'debugUser';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecipientBloc(
        repo: RecipientRepositoryFB(),
        userId: _userId(),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text(RecipientStrings.addRecipient),
        ),
        body: const RecipientForm(),
      ),
    );
  }
}

class RecipientForm extends StatefulWidget {
  const RecipientForm({super.key});

  @override
  State<RecipientForm> createState() => _RecipientFormState();
}

class _RecipientFormState extends State<RecipientForm> with TickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _accCtrl = TextEditingController();
  final _accFocus = FocusNode();

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _imageController;
  late AnimationController _formController;
  late AnimationController _buttonsController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _imageScale;
  late Animation<Offset> _imageSlide;
  late Animation<double> _formFade;
  late Animation<double> _buttonsFade;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _imageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _formController = AnimationController(
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
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    _imageScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.elasticOut),
    );

    _imageSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _imageController, curve: Curves.easeOut));

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOut),
    );

    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _imageController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _formController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _buttonsController.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _accCtrl.dispose();
    _accFocus.dispose();
    _headerController.dispose();
    _imageController.dispose();
    _formController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecipientBloc, AddRecipientState>(
      listenWhen: (p, c) => p.submitStatus != c.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == SubmitStatus.success) {
          showDialog(
            context: context,
            builder: (_) => _successDialog(context),
          );
        }
      },
      builder: (context, state) {
        _nameCtrl.value = _nameCtrl.value.copyWith(
            text: state.name,
            selection: TextSelection.collapsed(offset: state.name.length)
        );
        _accCtrl.value = _accCtrl.value.copyWith(
            text: state.accountNumber,
            selection: TextSelection.collapsed(offset: state.accountNumber.length)
        );

        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Animated Header
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: _header(),
              ),
            ),
            SizedBox(height: 24.h),

            // Animated Image Picker
            SlideTransition(
              position: _imageSlide,
              child: ScaleTransition(
                scale: _imageScale,
                child: _imagePicker(state),
              ),
            ),
            SizedBox(height: 20.h),

            // Animated Form Fields
            FadeTransition(
              opacity: _formFade,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_formController),
                child: AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 200),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 20.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        // Name Field
                        _input(
                          controller: _nameCtrl,
                          label: RecipientStrings.fullName,
                          hintText: RecipientStrings.enterFullName,
                          prefix: Icons.person_outline,
                          onChanged: (v) => context.read<RecipientBloc>().add(NameChanged(v)),
                        ),
                        SizedBox(height: 16.h),

                        // Bank Dropdown
                        BankDropdownWidget(state: state),
                        SizedBox(height: 16.h),

                        // Account Field
                        _accountField(state),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Error Banner
            if (state.errorMessage != null)
              FadeTransition(
                opacity: _formFade,
                child: _errorBanner(state.errorMessage!),
              ),

            SizedBox(height: 16.h),

            // Animated Buttons
            FadeTransition(
              opacity: _buttonsFade,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(_buttonsController),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 56.h,
                        child: OutlinedButton.icon(
                          onPressed: state.submitStatus == SubmitStatus.submitting ||
                              state.verifyStatus == VerifyStatus.verifying
                              ? null
                              : () => context.read<RecipientBloc>().add(const SubmitPressed(addAnother: true)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: MyTheme.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: const Icon(Icons.add, color: MyTheme.primaryColor),
                          label: Text(
                            RecipientStrings.saveAndAddAnother,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(flex: 2, child: _submitButton(state)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: MyTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_add_outlined, color: MyTheme.primaryColor, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(RecipientStrings.addNewRecipient, style: AppStyles.subtitle),
                SizedBox(height: 8.h),
                Text(RecipientStrings.recipientDetails, style: AppStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePicker(AddRecipientState state) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () => _showImagePickerOptions(context),
          child: Container(
            width: 100.r,
            height: 100.r,
            decoration: BoxDecoration(
              color: state.imageFile != null ? null : MyTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: MyTheme.primaryColor.withOpacity(0.3),
                  width: 2
              ),
              image: state.imageFile != null ? DecorationImage(
                  image: FileImage(state.imageFile as File),
                  fit: BoxFit.cover
              ) : null,
            ),
            child: state.imageFile == null ?
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, color: MyTheme.primaryColor, size: 32.sp),
                SizedBox(height: 6.h),
                Text(
                  RecipientStrings.addPhoto,
                  style: TextStyle(
                    color: MyTheme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
                : null,
          ),
        ),
      ),
    );
  }

  Future<void> _showImagePickerOptions(BuildContext context) async {
    final picker = ImagePicker();
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))
      ),
      builder: (_) => SafeArea(
        child: AnimationLimiter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 150),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text(RecipientStrings.takePhoto),
                  onTap: () async {
                    Navigator.pop(context);
                    final x = await picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 80
                    );
                    if (x != null) {
                      context.read<RecipientBloc>().add(PickImageRequested(File(x.path)));
                    }
                    HapticFeedback.selectionClick();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text(RecipientStrings.chooseFromGallery),
                  onTap: () async {
                    Navigator.pop(context);
                    final x = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 80
                    );
                    if (x != null) {
                      context.read<RecipientBloc>().add(PickImageRequested(File(x.path)));
                    }
                    HapticFeedback.selectionClick();
                  },
                ),
                if (context.read<RecipientBloc>().state.imageFile != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<RecipientBloc>().add(RemovePhotoRequested());
                      HapticFeedback.selectionClick();
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text(RecipientStrings.cancel),
                  onTap: () {
                    Navigator.pop(context);
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefix,
    required Function(String) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                    color: AppColors.secondaryBlue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2)
                )
              ],
            ),
            child: AppTextormField(
              controller: controller,
              onChanged: onChanged,
              isPasswordField: false,
              helpText: hintText,
              prefixIcon: Icon(prefix,color: MyTheme.primaryColor,),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountField(AddRecipientState state) {
    final bloc = context.read<RecipientBloc>();
    final verifying = state.verifyStatus == VerifyStatus.verifying;
    final verified = state.verifyStatus == VerifyStatus.verified;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Text(
              RecipientStrings.accountNumber,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                    color: AppColors.secondaryBlue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2)
                )
              ],
              border: verified ? Border.all(color: Colors.green, width: 1) : null,
            ),
            child: TextField(
              controller: _accCtrl,
              focusNode: _accFocus,
              onChanged: (v) => bloc.add(AccountNumberChanged(v)),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              onEditingComplete: () {
                if (state.accountError == null && state.accountNumber.isNotEmpty && state.verifyStatus != VerifyStatus.verified) {
                  bloc.add(VerifyAccountRequested());
                }
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: RecipientStrings.enterAccountNumber,
                hintStyle: const TextStyle(
                  fontSize: 14,
                ),
                errorText: state.accountError,
                prefixIcon: Icon(Icons.credit_card_outlined, color: MyTheme.primaryColor, size: 22.sp),
                suffixIcon: verifying ?
                Padding(
                  padding: EdgeInsets.all(12.r),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: MyTheme.primaryColor
                    ),
                  ),
                ) :
                verified ?
                Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 18.sp),
                      SizedBox(width: 6.w),
                      Text(
                          'Verified',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500
                          )
                      ),
                      SizedBox(width: 8.w),
                    ]
                ) :
                (state.accountNumber.isNotEmpty && state.accountError == null) ?
                InkWell(
                  onTap: () {
                    bloc.add(VerifyAccountRequested());
                    HapticFeedback.mediumImpact();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      'Verify',
                      style: TextStyle(
                        color: MyTheme.primaryColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ) : null,
                contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: MyTheme.primaryColor.withOpacity(0.3),
                    width: 1.2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      color: AppColors.errorRed.withOpacity(0.5),
                      width: 1.2
                  ),
                ),
              ),
              style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner(String message) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.3), width: 1),
      ),
      child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.errorRed, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
                child: Text(
                    message,
                    style: TextStyle(color: AppColors.errorRed, fontSize: 14.sp)
                )
            ),
          ]
      ),
    );
  }

  Widget _submitButton(AddRecipientState state) {
    final bloc = context.read<RecipientBloc>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56.h,
      child: ElevatedButton(
        onPressed: (state.submitStatus == SubmitStatus.submitting ||
            state.verifyStatus == VerifyStatus.verifying)
            ? null
            : () {
          HapticFeedback.mediumImpact();
          FocusScope.of(context).unfocus();
          bloc.add(const SubmitPressed());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: MyTheme.primaryColor,
          padding: EdgeInsets.zero,
          disabledBackgroundColor: MyTheme.primaryColor.withOpacity(0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
        child: state.submitStatus == SubmitStatus.submitting
            ? SizedBox(
            width: 24.w,
            height: 24.h,
            child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5
            )
        )
            : Text(
            RecipientStrings.addButtonText,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white
            )
        ),
      ),
    );
  }

  Widget _successDialog(BuildContext context) {
    return AlertDialog(
      title: Text(RecipientStrings.successTitle),
      content: Text(RecipientStrings.successMessage),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            Navigator.pop(context, {'action': 'back_to_list'});
          },
          child: Text(
              RecipientStrings.backToRecipients,
              style: const TextStyle(color: MyTheme.primaryColor)
          ),
        ),
      ],
    );
  }
}