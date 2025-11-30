import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/data/repositories/recipient/recipient_repository.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../data/models/recipient/recipient_model.dart';
import '../../../../logic/blocs/recipient/recipient_bloc.dart';
import '../../../../logic/blocs/recipient/recipient_event.dart';
import '../../../../logic/blocs/recipient/recipient_state.dart';
import '../../send_money/add_recipient_screen.dart';

class ContactSelectorWidget extends StatefulWidget {
  final RecipientModel? selectedRecipient;
  final Function(RecipientModel)? onRecipientSelected;

  const ContactSelectorWidget({
    super.key,
    this.selectedRecipient,
    this.onRecipientSelected,
  });

  @override
  State<ContactSelectorWidget> createState() => _ContactSelectorWidgetState();
}

class _ContactSelectorWidgetState extends State<ContactSelectorWidget> {
  RecipientModel? _selectedRecipient;

  @override
  void initState() {
    super.initState();
    _selectedRecipient = widget.selectedRecipient;

    // Load recipients when widget initializes
    context.read<RecipientBloc>().add(RecipientsSubscriptionRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipientBloc, AddRecipientState>(
      builder: (BuildContext context, AddRecipientState state) {
        return Column(
          children: <Widget>[
            // "Select Recipient" text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Select Recipient',
                  style: Font.montserratFont(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextButton.icon(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (BuildContext context) => const AddRecipientScreen()),
                    );
                  },
                  label: Text("Add New",style: Font.montserratFont(fontWeight: FontWeight.w600,color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),),
                  icon: Icon(Icons.add,color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                )
              ],
            ),
            SizedBox(height: 16.h),

            // Contact selection card
            if (_selectedRecipient != null) ...<Widget>[
              _buildContactCard(_selectedRecipient!),
              // Change contact option
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () {
                  _showContactSelector(context, state);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Change Recipient',
                      style: Font.montserratFont(
                        color: MyTheme.primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_drop_down,
                      color: MyTheme.primaryColor,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ] else
            // Button to select a contact
              GestureDetector(
                onTap: () {
                  _showContactSelector(context, state);
                },
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ],
                    border: Border.all(color: MyTheme.primaryColor, width: 1.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_add_rounded,
                        color: MyTheme.primaryColor,
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Select Recipient',
                        style: Font.montserratFont(
                          color: MyTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContactCard(RecipientModel recipient) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
        border: Border.all(
          color: MyTheme.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: <Widget>[
          // Contact avatar
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MyTheme.primaryColor.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: recipient.imageUrl.isNotEmpty
                  ? Image.network(
                recipient.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _buildContactFallback(recipient),
              )
                  : _buildContactFallback(recipient),
            ),
          ),
          SizedBox(width: 12.w),
          // Contact details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  recipient.name,
                  style: Font.montserratFont(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  semanticsLabel: 'Contact name: ${recipient.name}',
                ),
                SizedBox(height: 4.h),
                Text(
                  '${recipient.institutionName} - ${_formatAccountNumber(recipient.accountNumber)}',
                  style: Font.montserratFont(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Check icon
          Icon(Icons.check_circle, color: MyTheme.primaryColor, size: 24.sp),
        ],
      ),
    );
  }

  Widget _buildContactFallback(RecipientModel recipient) {
    return Center(
      child: Text(
        recipient.name.isNotEmpty ? recipient.name[0].toUpperCase() : '?',
        style: Font.montserratFont(
          color: MyTheme.primaryColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;

    // Show first 2 and last 4 digits with asterisks in between
    final String start = accountNumber.substring(0, 2);
    final String end = accountNumber.substring(accountNumber.length - 4);
    return '$start****$end';
  }

  void _showContactSelector(BuildContext context, AddRecipientState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: -5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                children: <Widget>[
                  // Drag handle
                  Container(
                    width: 50.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Select Recipient',
                    style: Font.montserratFont(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    semanticsLabel: 'Select payment recipient',
                  ),
                  SizedBox(height: 16.h),

                  // Search bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: TextField(
                      onChanged: (String query) {
                        context.read<RecipientBloc>().add(
                          RecipientsSearchChanged(query),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search recipients',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: MyTheme.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Recipients list
                  Expanded(
                    child: BlocProvider(
                      create: (_) => RecipientBloc(
                        repo: RecipientRepositoryFB(),
                        userId: FirebaseAuth.instance.currentUser!.uid,
                      ),
                      child: BlocBuilder<RecipientBloc, AddRecipientState>(
                        builder: (BuildContext context, AddRecipientState blocState) {
                          if (blocState.recipientsStatus == RecipientsStatus.loading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: MyTheme.primaryColor,
                              ),
                            );
                          }

                          if (blocState.recipientsStatus == RecipientsStatus.failure) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.grey[400],
                                    size: 48.sp,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Failed to load recipients',
                                    style: Font.montserratFont(
                                      color: Colors.grey[600],
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextButton(
                                    onPressed: () {
                                      context.read<RecipientBloc>().add(
                                        RecipientsSubscriptionRequested(),
                                      );
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (blocState.filteredRecipients.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.people_outline,
                                    color: Colors.grey[400],
                                    size: 48.sp,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    blocState.searchQuery.isNotEmpty
                                        ? 'No recipients found'
                                        : 'No recipients added yet',
                                    style: Font.montserratFont(
                                      color: Colors.grey[600],
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: blocState.filteredRecipients.length,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemBuilder: (BuildContext context, int index) {
                              final RecipientModel recipient = blocState.filteredRecipients[index];
                              final bool isSelected = _selectedRecipient?.id == recipient.id;

                              return Material(
                                color: isSelected
                                    ? MyTheme.primaryColor.withOpacity(0.08)
                                    : Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedRecipient = recipient;
                                    });
                                    widget.onRecipientSelected?.call(recipient);
                                    HapticFeedback.selectionClick();
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4.h),
                                    child: ListTile(
                                      leading: Container(
                                        width: 48.r,
                                        height: 48.r,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? MyTheme.primaryColor.withOpacity(0.15)
                                              : MyTheme.primaryColor.withOpacity(0.1),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(24.r),
                                          child: recipient.imageUrl.isNotEmpty
                                              ? Image.network(
                                            recipient.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _buildContactFallback(recipient),
                                          )
                                              : _buildContactFallback(recipient),
                                        ),
                                      ),
                                      title: Text(
                                        recipient.name,
                                        style: Font.montserratFont(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${recipient.institutionName} - ${_formatAccountNumber(recipient.accountNumber)}',
                                        style: Font.montserratFont(
                                          fontSize: 14.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? Icon(
                                        Icons.check_circle,
                                        color: MyTheme.primaryColor,
                                        size: 20.sp,
                                      )
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}