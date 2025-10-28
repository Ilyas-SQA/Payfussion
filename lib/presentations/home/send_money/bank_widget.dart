import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/constants/app_colors.dart';
import 'package:payfussion/data/models/recipient/recipient_model.dart';
import 'package:payfussion/logic/blocs/recipient/recipient_bloc.dart';
import 'package:payfussion/logic/blocs/recipient/recipient_event.dart';
import 'package:payfussion/logic/blocs/recipient/recipient_state.dart';
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';

import '../../../core/theme/theme.dart';
import 'add_recipient_screen.dart';

class BankDropdownWidget extends StatelessWidget {
  final AddRecipientState state;
  final FocusNode? accountFocusNode;

  const BankDropdownWidget({
    Key? key,
    required this.state,
    this.accountFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SizedBox(height: 8.h),
        _buildBankSelector(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        RecipientStrings.bankName,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildBankSelector(BuildContext context) {
    return Column(
      children: [
        // Main Bank Selection Container
        GestureDetector(
          onTap: () => _showBankSelectionModal(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12.r),
              border: state.bankError != null ? Border.all(color: Colors.red, width: 1) : Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryBlue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_outlined,
                  color: MyTheme.primaryColor,
                  size: 22.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    state.selectedBank?.name ?? RecipientStrings.selectBank,
                    style: TextStyle(
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                if (state.selectedBank != null)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18.sp,
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: MyTheme.primaryColor,
                    size: 24.sp,
                  ),
              ],
            ),
          ),
        ),

        // Bank Details Section (shown when bank is selected)
        if (state.selectedBank != null) ...[
          SizedBox(height: 12.h),
          _buildBankDetailsCard(context,state.selectedBank!),
        ],

        // Error message for bank selection
        if (state.bankError != null) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                state.bankError!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBankDetailsCard(context,Bank bank) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MyTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: MyTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with bank name and change button
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: MyTheme.primaryColor,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Bank Details',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: MyTheme.primaryColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showBankSelectionModal(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: MyTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      color: MyTheme.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Bank details grid
          _buildDetailRow('Bank Name', bank.name),

          if (bank.code.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildDetailRow('Bank Code', bank.code),
          ],

          if (bank.branchName.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildDetailRow('Branch Name', bank.branchName),
          ],

          if (bank.branchCode.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildDetailRow('Branch Code', bank.branchCode),
          ],

          if (bank.address.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildDetailRow('Address', bank.address),
          ],

          if (bank.city.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildDetailRow('City', bank.city),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showBankSelectionModal(BuildContext context) {
    final bloc = context.read<RecipientBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (BuildContext context) => BlocProvider.value(
        value: bloc,
        child: BankSelectionModal(
          selectedBank: state.selectedBank,
          banks: state.filteredBanks,
          isLoading: state.banksLoading,
          onBankSelected: (bank) {
            bloc.add(BankChanged(bank));
            if (accountFocusNode != null) {
              FocusScope.of(context).requestFocus(accountFocusNode);
            }
            Navigator.pop(context);
            HapticFeedback.selectionClick();
          },
        ),
      ),
    );
  }
}

class BankSelectionModal extends StatefulWidget {
  final Bank? selectedBank;
  final List<Bank> banks;
  final bool isLoading;
  final Function(Bank) onBankSelected;

  const BankSelectionModal({
    Key? key,
    required this.selectedBank,
    required this.banks,
    required this.isLoading,
    required this.onBankSelected,
  }) : super(key: key);

  @override
  State<BankSelectionModal> createState() => _BankSelectionModalState();
}

class _BankSelectionModalState extends State<BankSelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              _buildModalHeader(),
              _buildSearchField(),
              _buildBankList(scrollController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Icon(
            Icons.account_balance,
            color: MyTheme.primaryColor,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Select Bank',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showAddBankModal(context),
            icon: Icon(
              Icons.add_business,
              color: MyTheme.primaryColor,
              size: 24.sp,
            ),
            tooltip: 'Add New Bank',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: AppTextFormField(
        controller: _searchController,
        onChanged: (query) {
          context.read<RecipientBloc>().add(BankSearchChanged(query));
        },

        prefixIcon: Icon(
          Icons.search,
          color: MyTheme.primaryColor,
          size: 20.sp,
        ),
        isPasswordField: false,
        helpText: 'Search banks....',
      ),
    );
  }

  Widget _buildBankList(ScrollController scrollController) {
    return Expanded(
      child: BlocBuilder<RecipientBloc, AddRecipientState>(
        builder: (context, state) {
          if (state.banksLoading) {
            return const Center(
              child: CircularProgressIndicator(color: MyTheme.primaryColor),
            );
          }

          if (state.filteredBanks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No banks found',
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: () => _showAddBankModal(context),
                    child: const Text(
                      'Add New Bank',
                      style: TextStyle(color: MyTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: scrollController,
            itemCount: state.filteredBanks.length,
            itemBuilder: (context, index) {
              final bank = state.filteredBanks[index];
              final isSelected = widget.selectedBank?.id == bank.id;

              return ListTile(
                onTap: () => widget.onBankSelected(bank),
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: MyTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: MyTheme.primaryColor,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  bank.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: bank.code.isNotEmpty
                    ? Text(
                  'Code: ${bank.code}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                )
                    : null,
                trailing: isSelected
                    ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20.sp,
                )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  void _showAddBankModal(BuildContext context) {
    Navigator.of(context).pop(); // Close bank selection modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<RecipientBloc>(),
        child: const AddBankModal(),
      ),
    );
  }
}

class AddBankModal extends StatefulWidget {
  const AddBankModal({Key? key}) : super(key: key);

  @override
  State<AddBankModal> createState() => _AddBankModalState();
}

class _AddBankModalState extends State<AddBankModal> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _bankCodeController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _branchCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _bankNameController.dispose();
    _bankCodeController.dispose();
    _branchNameController.dispose();
    _branchCodeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              _buildAddBankHeader(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.all(16.w),
                    children: [
                      _buildTextField(
                        controller: _bankNameController,
                        label: 'Bank Name *',
                        hint: 'e.g., Habib Bank Limited',
                        icon: Icons.account_balance,
                        isRequired: true,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _bankCodeController,
                        label: 'Bank Code / SWIFT Code',
                        hint: 'e.g., HABBPKKA',
                        icon: Icons.code,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _branchNameController,
                        label: 'Branch Name',
                        hint: 'e.g., Main Branch',
                        icon: Icons.business,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _branchCodeController,
                        label: 'Branch Code',
                        hint: 'e.g., 0001',
                        icon: Icons.pin,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        hint: 'e.g., I.I. Chundrigar Road',
                        icon: Icons.location_on,
                        maxLines: 2,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _cityController,
                        label: 'City / Location',
                        hint: 'e.g., Karachi',
                        icon: Icons.location_city,
                      ),
                      SizedBox(height: 24.h),
                      _buildSubmitButton(),
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

  Widget _buildAddBankHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: MyTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.add_business,
              color: MyTheme.primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Bank',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Fill in the bank details',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: MyTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: MyTheme.primaryColor, width: 2),
        ),
      ),
      validator: isRequired
          ? (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        if (value.trim().length < 2) {
          return '$label must be at least 2 characters';
        }
        return null;
      }
          : null,
    );
  }

  Widget _buildSubmitButton() {
    return BlocConsumer<RecipientBloc, AddRecipientState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          if (state.errorMessage!.contains('successfully')) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: state.isAddingBank ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isAddingBank
                  ? AppColors.textSecondary
                  : MyTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: state.isAddingBank
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Adding Bank...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
                : Text(
              'Add Bank',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final bankData = {
      'name': _bankNameController.text.trim(),
      'code': _bankCodeController.text.trim(),
      'branchName': _branchNameController.text.trim(),
      'branchCode': _branchCodeController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
    };

    context.read<RecipientBloc>().add(AddNewBankEvent(bankData));
  }
}