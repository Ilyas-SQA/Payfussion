// lib/presentations/home/send_money/send_money_home.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:payfussion/data/models/recipient/recipient_model.dart';
import 'package:payfussion/presentations/home/send_money/payment_screen.dart' hide AppStyles, AppDurations;
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../data/repositories/recipient/recipient_repository.dart';
import '../../../logic/blocs/recipient/recipient_bloc.dart';
import '../../../logic/blocs/recipient/recipient_event.dart';
import '../../../logic/blocs/recipient/recipient_state.dart';
import 'add_recipient_screen.dart';

class SendMoneyHome extends StatelessWidget {
  const SendMoneyHome({super.key});

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
          title: const Text(
            AppStrings.sendMoney,
            semanticsLabel: 'Send Money Screen',
          ),
          actions: [
            _AddRecipientButton(
              onPressed: () => _navigateToAddRecipient(context),
            ),
          ],
        ),
        body: const RecipientsList(),
      ),
    );
  }

  Future<void> _navigateToAddRecipient(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRecipientScreen()),
    );
    // 🔁 Stream auto-updates via Firestore; no manual refresh needed.
  }
}

class _AddRecipientButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddRecipientButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      icon: Icon(
        Icons.person_add_outlined,
        size: 18.sp,
        color: MyTheme.primaryColor,
      ),
      label: const Text(
        AppStrings.addNew,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: MyTheme.primaryColor,
        ),
        semanticsLabel: 'Add new recipient button',
      ),
    );
  }
}

class RecipientsList extends StatefulWidget {
  const RecipientsList({super.key});

  @override
  State<RecipientsList> createState() => _RecipientsListState();
}

class _RecipientsListState extends State<RecipientsList> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: AnimatedContainer(
        duration: AppDurations.quickAnimation,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryBlue.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AppTextFormField(
          controller: _searchController,
          onChanged: (q) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(AppDurations.searchDebounce, () {
              context.read<RecipientBloc>().add(RecipientsSearchChanged(q));
              // Force rebuild of clear icon state
              if (mounted) setState(() {});
            });
          },
          prefixIcon: Icon(
            Icons.search,
            size: 20.sp,
            color: MyTheme.primaryColor,
          ),
          isPasswordField: false,
          helpText: 'Search recipients',
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return GestureDetector(
      onTap: () {
        _searchController.clear();
        context.read<RecipientBloc>().add(const RecipientsSearchChanged(''));
        HapticFeedback.lightImpact();
        setState(() {});
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            color: Colors.grey[600],
            size: 18.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<RecipientBloc, AddRecipientState>(
      builder: (context, state) {
        if (state.recipientsStatus == RecipientsStatus.loading) {
          return _buildLoadingState();
        }
        if (state.recipientsStatus == RecipientsStatus.failure) {
          return _buildErrorState(context, 'Failed to load recipients');
        }
        if (state.allRecipients.isEmpty) {
          return _buildEmptyState(context);
        }
        if (state.filteredRecipients.isEmpty) {
          return _buildNoResultsState();
        }
        return _buildRecipientsList(state.filteredRecipients);
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: Container(
              height: 70.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientsList(List<RecipientModel> recipients) {
    return RefreshIndicator(
      color: MyTheme.primaryColor,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        // Firestore stream auto-refreshes; just delay for UI polish
        await Future.delayed(const Duration(milliseconds: 350));
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: recipients.length,
          itemBuilder: (context, index) {
            final r = recipients[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: RecipientTile(
                    recipient: r,
                    onTap: () => navigateToPaymentScreen(context, r),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: MyTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 60.sp,
                color: MyTheme.primaryColor,
                semanticLabel: 'No recipients icon',
              ),
            ),
            SizedBox(height: 20.h),
            Text(AppStrings.noRecipientsYet, style: AppStyles.subtitle),
            SizedBox(height: 12.h),
            Text(
              AppStrings.addRecipientPrompt,
              textAlign: TextAlign.center,
              style: AppStyles.caption,
            ),
            SizedBox(height: 30.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddRecipientScreen()),
                );
              },
              child: Text(
                AppStrings.addRecipient,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24.r),
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 50.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16.h),
            Text(AppStrings.noMatchingRecipients, style: AppStyles.subtitle),
            SizedBox(height: 8.h),
            Text(
              AppStrings.tryDifferentSearch,
              textAlign: TextAlign.center,
              style: AppStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24.r),
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60.sp,
                color: AppColors.errorRed,
                semanticLabel: 'Error icon',
              ),
            ),
            SizedBox(height: 20.h),
            Text(AppStrings.somethingWentWrong, style: AppStyles.subtitle),
            SizedBox(height: 12.h),
            Text(message, textAlign: TextAlign.center, style: AppStyles.caption),
            SizedBox(height: 30.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Re-subscribe
                context.read<RecipientBloc>().add(RecipientsSubscriptionRequested());
                HapticFeedback.mediumImpact();
              },
              label: Text(
                AppStrings.tryAgain,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToPaymentScreen(BuildContext context, RecipientModel recipient) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(recipient: recipient),
      ),
    );
  }
}

class RecipientTile extends StatelessWidget {
  final RecipientModel recipient;
  final VoidCallback onTap;

  const RecipientTile({
    super.key,
    required this.recipient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: MyTheme.primaryColor.withOpacity(0.1),
            highlightColor: MyTheme.primaryColor.withOpacity(0.05),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              child: Row(
                children: [
                  Hero(
                    tag: 'recipient_image_${recipient.id}',
                    child: _buildAvatar(),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recipient.name),
                        SizedBox(height: 4.h),
                        Text(
                          'Bank Account (${recipient.institutionName})',
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "**** **** **** ${recipient.accountNumber.substring(recipient.accountNumber.length - 4)}",
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: MyTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(8.r),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 16.sp,
                      color: MyTheme.primaryColor,
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

  Widget _buildAvatar() {
    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MyTheme.primaryColor.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26.r),
        child: recipient.imageUrl.isNotEmpty
            ? Image.network(
          recipient.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildAvatarFallback(),
        )
            : _buildAvatarFallback(),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Text(
        recipient.name.isNotEmpty ? recipient.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: MyTheme.primaryColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
