import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';
import '../../../core/constants/fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/recipient/recipient_model.dart';
import '../../../logic/blocs/bank_transaction/bank_transaction_bloc.dart';
import '../../../logic/blocs/bank_transaction/bank_transaction_event.dart';
import '../../../logic/blocs/bank_transaction/bank_transaction_state.dart';
import '../../widgets/background_theme.dart';

class SelectBankScreen extends StatefulWidget {
  const SelectBankScreen({Key? key}) : super(key: key);

  @override
  State<SelectBankScreen> createState() => _SelectBankScreenState();
}

class _SelectBankScreenState extends State<SelectBankScreen> with TickerProviderStateMixin{

  late AnimationController _backgroundAnimationController;


  @override
  void initState() {
    super.initState();
    context.read<BankTransactionBloc>().add(const FetchBanks());
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

  void _toggleBankSelection(Bank bank, bool isCurrentlySelected) {
    if (isCurrentlySelected) {
      // Unselect the bank
      context.read<BankTransactionBloc>().add(const BankUnselected());
    } else {
      // Select the bank
      context.read<BankTransactionBloc>().add(BankSelected(bank));
    }
  }

  void _proceedToBankDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const BankDetailsScreen(),
      ),
    );
  }

  Widget _buildBankCard(Bank bank, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        gradient: isSelected ?
        LinearGradient(
          colors: <Color>[MyTheme.primaryColor, MyTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _toggleBankSelection(bank, isSelected),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: bank.image.isEmpty ? 'https://via.placeholder.com/50' : bank.image,
                  height: 50,
                  width: 50,
                  placeholder: (BuildContext context, String url) => const CircularProgressIndicator(),
                  errorWidget: (BuildContext context, String url, Object error) => const Icon(Icons.error),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      bank.name,
                      style: Font.montserratFont(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (bank.branchName.isNotEmpty)
                      Text(
                        bank.branchName,
                        style: Font.montserratFont(
                          fontSize: 12.sp,
                        ),
                      ),
                    if (bank.city.isNotEmpty)
                      Text(
                        bank.city,
                        style: Font.montserratFont(
                          fontSize: 11.sp,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.check,
                    color: MyTheme.primaryColor,
                    size: 16.sp,
                  ),
                )
              else
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Bank',
          style: Font.montserratFont(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          BlocConsumer<BankTransactionBloc, BankTransactionState>(
            listener: (BuildContext context, BankTransactionState state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (BuildContext context, BankTransactionState state) {
              return Column(
                children: <Widget>[
                  // Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Choose your bank',
                          style: Font.montserratFont(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Select a bank from the list below (tap again to unselect)',
                          style: Font.montserratFont(
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Banks List
                  Expanded(
                    child: state.isLoadingBanks
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: MyTheme.primaryColor,
                      ),
                    )
                        : state.availableBanks.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.account_balance_outlined,
                            size: 64.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No Banks Available',
                            style: Font.montserratFont(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                      itemCount: state.availableBanks.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Bank bank = state.availableBanks[index];
                        final bool isSelected = state.selectedBank?.id == bank.id;
                        return _buildBankCard(bank, isSelected);
                      },
                    ),
                  ),

                  // Continue Button
                  if (state.hasSelectedBank)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      child: ElevatedButton(
                        onPressed: _proceedToBankDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyTheme.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Continue',
                              style: Font.montserratFont(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Updated BankDetailsScreen with MyTheme.primaryColor
class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> with TickerProviderStateMixin{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _paymentPurposeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  late AnimationController _backgroundAnimationController;

  String? _selectedPurpose;
  final List<String> _paymentPurposes = <String>[
    'Salary Transfer',
    'Bill Payment',
    'Personal Transfer',
    'Business Payment',
    'Education Fee',
    'Medical Payment',
    'Investment',
    'Shopping',
    'Other',
  ];
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
    _accountNumberController.dispose();
    _paymentPurposeController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  String? _validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }
    if (value.length < 10 || value.length > 20) {
      return 'Account number must be 10-20 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Account number must contain only digits';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^(\+92|92|0)?[0-9]{10}$').hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validatePaymentPurpose(String? value) {
    if (value == null || value.isEmpty) {
      return 'Payment purpose is required';
    }
    return null;
  }

  void _submitDetails() {
    if (_formKey.currentState!.validate()) {
      final String accountNumber = _accountNumberController.text.trim();
      final String paymentPurpose = _selectedPurpose == 'Other'
          ? _paymentPurposeController.text.trim()
          : _selectedPurpose!;
      final String phoneNumber = _phoneNumberController.text.trim();

      // Get selected bank from state
      final Bank? selectedBank = context.read<BankTransactionBloc>().state.selectedBank;

      if (selectedBank != null) {
        // Submit details to bloc
        context.read<BankTransactionBloc>().add(
          BankDetailsSubmitted(
            accountNumber: accountNumber,
            paymentPurpose: paymentPurpose,
            phoneNumber: phoneNumber,
            bank: selectedBank,
          ),
        );

        // Navigate to amount screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const BankTransferAmountScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Bank Details',
          style: Font.montserratFont(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          BlocConsumer<BankTransactionBloc, BankTransactionState>(
            listener: (BuildContext context, BankTransactionState state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (BuildContext context, BankTransactionState state) {
              return Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    // Selected Bank Info
                    if (state.selectedBank != null)
                      Container(
                        margin: EdgeInsets.all(16.w),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[MyTheme.primaryColor, MyTheme.primaryColor.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25.r),
                              child: Container(
                                width: 50.w,
                                height: 50.w,
                                color: Colors.white,
                                child: state.selectedBank!.image.isNotEmpty
                                    ? CachedNetworkImage(
                                  imageUrl: state.selectedBank!.image,
                                  fit: BoxFit.cover,
                                  placeholder: (BuildContext context, String url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: MyTheme.primaryColor,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (BuildContext context, String url, Object error) => Icon(
                                    Icons.account_balance,
                                    color: MyTheme.primaryColor,
                                    size: 24.sp,
                                  ),
                                )
                                    : Icon(
                                  Icons.account_balance,
                                  color: MyTheme.primaryColor,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    state.selectedBank!.name,
                                    style: Font.montserratFont(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (state.selectedBank!.branchName.isNotEmpty) ...<Widget>[
                                    SizedBox(height: 4.h),
                                    Text(
                                      state.selectedBank!.branchName,
                                      style: Font.montserratFont(
                                        fontSize: 12.sp,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ],
                        ),
                      ),

                    // Form Fields
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Enter Transfer Details',
                              style: Font.montserratFont(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // Account Number Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Account Number',
                                  style: Font.montserratFont(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                AppTextFormField(
                                  controller: _accountNumberController,
                                  validator: _validateAccountNumber,
                                  keyboardType: TextInputType.number,
                                  helpText: 'Enter account number',
                                  prefixIcon: const Icon(Icons.account_balance_wallet),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(13),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 24.h),

                            // Payment Purpose Dropdown
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Payment Purpose',
                                  style: Font.montserratFont(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedPurpose,
                                  validator: _validatePaymentPurpose,
                                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                                  decoration: InputDecoration(
                                    hintText: 'Select payment purpose',
                                    hintStyle: Font.montserratFont(color: Colors.white),
                                  ),

                                  items: _paymentPurposes.map((String purpose) {
                                    return DropdownMenuItem<String>(
                                      value: purpose,
                                      child: Text(purpose,style: Font.montserratFont(color: Theme.brightnessOf(context) == Brightness.light ? Colors.black : Colors.white),),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedPurpose = newValue;
                                    });
                                  },
                                ),
                                if (_selectedPurpose == 'Other') ...<Widget>[
                                  SizedBox(height: 16.h),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Specify Purpose',
                                        style: Font.montserratFont(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      AppTextFormField(
                                        controller: _paymentPurposeController,
                                        validator: _validatePaymentPurpose,
                                        helpText: 'Enter payment purpose',
                                        keyboardType: TextInputType.number,
                                        prefixIcon: const Icon(Icons.account_balance_wallet),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),

                            SizedBox(height: 24.h),

                            // Phone Number Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Phone Number',
                                  style: Font.montserratFont(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                AppTextFormField(
                                  controller: _phoneNumberController,
                                  validator: _validatePhoneNumber,
                                  keyboardType: TextInputType.number,
                                  helpText: '+92 300 1234567',
                                  prefixIcon: const Icon(Icons.phone),
                                ),
                              ],
                            ),

                            SizedBox(height: 32.h),

                            // Info Card
                            Container(
                              padding: EdgeInsets.all(16.w),
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
                                  Icon(
                                    Icons.info_outline,
                                    color: MyTheme.primaryColor,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      'Please ensure all details are correct. Account number should be verified with the bank.',
                                      style: Font.montserratFont(
                                        fontSize: 12.sp,
                                        color: MyTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Continue Button
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      child: ElevatedButton(
                        onPressed: _submitDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyTheme.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Continue',
                          style: Font.montserratFont(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Bank Transfer Amount Screen with MyTheme.primaryColor
class BankTransferAmountScreen extends StatefulWidget {
  const BankTransferAmountScreen({Key? key}) : super(key: key);

  @override
  State<BankTransferAmountScreen> createState() => _BankTransferAmountScreenState();
}

class _BankTransferAmountScreenState extends State<BankTransferAmountScreen> with TickerProviderStateMixin{
  final TextEditingController _amountController = TextEditingController();
  late AnimationController _backgroundAnimationController;


  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _processTransfer() {
    context.read<BankTransactionBloc>().add(const ProcessBankTransfer());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _amountController.addListener(() {
      String text = _amountController.text;

      // remove $
      if (text.startsWith('\$')) {
        text = text.replaceFirst('\$', '').trim();
      }

      // avoid infinite loop
      _amountController.value = _amountController.value.copyWith(
        text: '\$ $text',
        selection: TextSelection.collapsed(
          offset: ('\$ $text').length,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BankTransactionBloc, BankTransactionState>(
      listener: (BuildContext context, BankTransactionState state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bank transfer completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.popUntil(context, (Route route) => route.isFirst);
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Enter Amount',
            style: Font.montserratFont(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
        ),
        body: Stack(
          children: <Widget>[
            AnimatedBackground(
              animationController: _backgroundAnimationController,
            ),
            BlocBuilder<BankTransactionBloc, BankTransactionState>(
              builder: (BuildContext context, BankTransactionState state) {
                return Column(
                  children: <Widget>[
                    // Bank Info Header
                    if (state.hasCompleteDetails)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Transfer to:',
                              style: Font.montserratFont(
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              state.selectedBank!.name,
                              style: Font.montserratFont(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Account: ${state.accountNumber}',
                              style: Font.montserratFont(
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              'Purpose: ${state.paymentPurpose}',
                              style: Font.montserratFont(
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Amount Input
                            Text(
                              'Enter Amount',
                              style: Font.montserratFont(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '\$ 0.00',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                errorText: state.amountError,
                              ),
                              onChanged: (value) {
                                final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
                                context.read<BankTransactionBloc>().add(
                                  BankTransferAmountChanged(clean),
                                );
                              },
                            ),

                            SizedBox(height: 24.h),

                            // Fee Display
                            if (state.amount > 0)
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Transfer Amount:', style: Font.montserratFont(fontSize: 14.sp)),
                                        Text(state.formattedAmount, style: Font.montserratFont(fontSize: 14.sp)),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Text(
                                              'Transaction Fee:',
                                              style: Font.montserratFont(fontSize: 14.sp),
                                            ),
                                            SizedBox(width: 4.w),
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12.r),
                                                    ),
                                                    title: Row(
                                                      children: [
                                                        Icon(Icons.info_outline, color: MyTheme.primaryColor),
                                                        SizedBox(width: 8.w),
                                                        Text(
                                                          'Transaction Fee',
                                                          style: Font.montserratFont(
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    content: Text(
                                                      'This fee covers payment processing and applicable taxes '
                                                          'required to complete your transfer.',
                                                      style: Font.montserratFont(fontSize: 14.sp),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: Icon(
                                                Icons.info_outline,
                                                size: 16.sp,
                                                color: MyTheme.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '\$${state.transactionFee.toStringAsFixed(2)}',
                                          style: Font.montserratFont(fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                    Divider(height: 16.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'Total Amount:',
                                          style: Font.montserratFont(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          state.formattedTotalAmount,
                                          style: Font.montserratFont(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: MyTheme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            const Spacer(),

                            // Transfer Button
                            Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state.canProcessTransfer && !state.isProcessing ? _processTransfer : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyTheme.primaryColor,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: state.isProcessing
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                  'Complete Transfer',
                                  style: Font.montserratFont(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  }