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
import '../../../core/constants/fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../data/repositories/recipient/recipient_repository.dart';
import '../../../logic/blocs/recipient/recipient_bloc.dart';
import '../../../logic/blocs/recipient/recipient_event.dart';
import '../../../logic/blocs/recipient/recipient_state.dart';
import '../../widgets/background_theme.dart';

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

  // Validation messages
  static const String nameRequired = 'Please enter recipient name';
  static const String bankRequired = 'Please select a bank';
  static const String accountRequired = 'Please enter account number';
}

class AddRecipientScreen extends StatefulWidget {
  const AddRecipientScreen({super.key});

  @override
  State<AddRecipientScreen> createState() => _AddRecipientScreenState();
}

class _AddRecipientScreenState extends State<AddRecipientScreen> with TickerProviderStateMixin{
  String _userId() => FirebaseAuth.instance.currentUser?.uid ?? 'debugUser';
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
        body: Stack(
          children: <Widget>[
            AnimatedBackground(
              animationController: _backgroundAnimationController,
            ),
            const RecipientForm(),
          ],
        ),
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
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _accCtrl = TextEditingController();
  final FocusNode _accFocus = FocusNode();

  // Validation state
  bool _showNameError = false;
  bool _showBankError = false;
  bool _showAccountError = false;

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

  void _validateAndSubmit({bool addAnother = false}) {
    final state = context.read<RecipientBloc>().state;

    setState(() {
      _showNameError = state.name.trim().isEmpty;
      _showBankError = state.selectedBank == null;
      _showAccountError = state.accountNumber.trim().isEmpty;
    });

    // If any validation fails, return
    if (_showNameError || _showBankError || _showAccountError) {
      HapticFeedback.mediumImpact();
      return;
    }

    // All validations passed, submit the form
    context.read<RecipientBloc>().add(SubmitPressed(addAnother: addAnother));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecipientBloc, AddRecipientState>(
      listenWhen: (AddRecipientState p, AddRecipientState c) =>
      p.submitStatus != c.submitStatus || p.selectedBank != c.selectedBank,
      listener: (BuildContext context, AddRecipientState state) {
        if (state.submitStatus == SubmitStatus.success) {
          // Reset validation errors on success
          setState(() {
            _showNameError = false;
            _showBankError = false;
            _showAccountError = false;
          });

          showDialog(
            context: context,
            builder: (_) => _successDialog(context),
          );
        }

        // Clear bank error when bank is selected
        if (state.selectedBank != null && _showBankError) {
          setState(() => _showBankError = false);
        }
      },
      builder: (BuildContext context, AddRecipientState state) {
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
          children: <Widget>[
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
                      childAnimationBuilder: (Widget widget) => SlideAnimation(
                        verticalOffset: 20.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: <Widget>[
                        // Name Field
                        _input(
                          controller: _nameCtrl,
                          label: RecipientStrings.fullName,
                          hintText: RecipientStrings.enterFullName,
                          prefix: Icons.person_outline,
                          onChanged: (String v) {
                            context.read<RecipientBloc>().add(NameChanged(v));
                            if (_showNameError && v.trim().isNotEmpty) {
                              setState(() => _showNameError = false);
                            }
                          },
                          showError: _showNameError,
                          errorText: RecipientStrings.nameRequired,
                        ),
                        SizedBox(height: 16.h),

                        // Bank Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BankDropdownWidget(
                              state: state.copyWith(
                                bankError: _showBankError ? RecipientStrings.bankRequired : null,
                              ),
                            ),
                          ],
                        ),
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

            // Animated Buttons
            FadeTransition(
              opacity: _buttonsFade,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(_buttonsController),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 56.h,
                        child: OutlinedButton.icon(
                          onPressed: state.submitStatus == SubmitStatus.submitting || state.verifyStatus == VerifyStatus.verifying
                              ? null
                              : () => _validateAndSubmit(addAnother: true),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: MyTheme.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: const Icon(Icons.add, color: MyTheme.primaryColor),
                          label: Text(
                            RecipientStrings.saveAndAddAnother,
                            style: Font.montserratFont(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
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
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
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
              children: <Widget>[
                Text(RecipientStrings.addNewRecipient, style: AppStyles.subtitle),
                SizedBox(height: 8.h),
                Text(RecipientStrings.recipientDetails, style: Font.montserratFont(fontSize: 12)),
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
                width: 2,
              ),
              image: state.imageFile != null ? DecorationImage(
                  image: FileImage(state.imageFile as File),
                  fit: BoxFit.cover
              ) : null,
            ),
            child: state.imageFile == null ?
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add_a_photo, color: MyTheme.primaryColor, size: 32.sp),
                SizedBox(height: 6.h),
                Text(
                  RecipientStrings.addPhoto,
                  style: Font.montserratFont(
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
    final ImagePicker picker = ImagePicker();
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
              childAnimationBuilder: (Widget widget) => SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(child: widget),
              ),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text(RecipientStrings.takePhoto),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? x = await picker.pickImage(
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
                    final XFile? x = await picker.pickImage(
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
                    title: Text('Remove Photo', style: Font.montserratFont(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<RecipientBloc>().add(RemovePhotoRequested());
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
    bool showError = false,
    String? errorText,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Text(
              label,
              style: Font.montserratFont(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppTextFormField(
            controller: controller,
            onChanged: onChanged,
            isPasswordField: false,
            helpText: hintText,
            prefixIcon: Icon(prefix, color: MyTheme.primaryColor),
          ),
          if (showError && errorText != null)
            Padding(
              padding: EdgeInsets.only(left: 4.w, top: 6.h),
              child: Text(
                errorText,
                style: Font.montserratFont(
                  fontSize: 12.sp,
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _accountField(AddRecipientState state) {
    final RecipientBloc bloc = context.read<RecipientBloc>();
    final bool verifying = state.verifyStatus == VerifyStatus.verifying;
    final bool verified = state.verifyStatus == VerifyStatus.verified;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Text(
              RecipientStrings.accountNumber,
              style: Font.montserratFont(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppTextFormField(
            controller: _accCtrl,
            focusNode: _accFocus,
            onChanged: (String v) {
              bloc.add(AccountNumberChanged(v));
              if (_showAccountError && v.trim().isNotEmpty) {
                setState(() => _showAccountError = false);
              }
            },
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            onEditingComplete: () {
              if (state.accountError == null && state.accountNumber.isNotEmpty && state.verifyStatus != VerifyStatus.verified) {
                bloc.add(VerifyAccountRequested());
              }
              FocusScope.of(context).unfocus();
            },
            suffixIcon: verifying ?
            Padding(
              padding: EdgeInsets.all(12.r),
              child: SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MyTheme.primaryColor,
                ),
              ),
            ) :
            verified ?
            Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.check_circle, color: Colors.green, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                      'Verified',
                      style: Font.montserratFont(
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
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Verify',
                  style: Font.montserratFont(
                    color: MyTheme.primaryColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ) : null,
            prefixIcon: Icon(Icons.credit_card_outlined, color: MyTheme.primaryColor, size: 22.sp),
            helpText: RecipientStrings.enterAccountNumber,
          ),
          if (_showAccountError)
            Padding(
              padding: EdgeInsets.only(left: 4.w, top: 6.h),
              child: Text(
                RecipientStrings.accountRequired,
                style: Font.montserratFont(
                  fontSize: 12.sp,
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _submitButton(AddRecipientState state) {
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
          _validateAndSubmit();
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
            style: Font.montserratFont(
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text(RecipientStrings.successTitle),
      content: const Text(RecipientStrings.successMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            Navigator.pop(context, <String, String>{'action': 'back_to_list'});
          },
          child: Text(
              RecipientStrings.backToRecipients,
              style: Font.montserratFont(color: MyTheme.primaryColor)
          ),
        ),
      ],
    );
  }
}