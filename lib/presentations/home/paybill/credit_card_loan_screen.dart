// Updated BankTransactionBloc to fetch from Firebase
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/routes_name.dart';
import '../../../data/models/recipient/recipient_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../logic/blocs/bank_transaction/bank_transaction_bloc.dart';
import '../../../logic/blocs/bank_transaction/bank_transaction_event.dart';
import '../../../logic/blocs/bank_transaction/bank_transaction_state.dart';

class CreditCardLoanScreen extends StatefulWidget {
  const CreditCardLoanScreen({Key? key}) : super(key: key);

  @override
  State<CreditCardLoanScreen> createState() => _CreditCardLoanScreenState();
}

class _CreditCardLoanScreenState extends State<CreditCardLoanScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BankTransactionBloc>().add(const FetchBanks());
  }

  void _navigateToBankDetails(Bank bank) {
    // Selected bank ko bloc mein set karein
    context.read<BankTransactionBloc>().add(BankSelected(bank));

    // Next screen par navigate karein
    context.push(
      RouteNames.payBillsDetailView,
      extra: {
        'billType': "creditcardloan",
        'companyName': bank.name,
        'plans': bank.branchName.isNotEmpty ? [bank.branchName] : [],
        'rating': 4.5,
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 80.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildBankCard(Bank bank) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      child: Container(
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
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _navigateToBankDetails(bank),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: MyTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: MyTheme.primaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (bank.branchName.isNotEmpty)
                        Text(
                          bank.branchName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      if (bank.city.isNotEmpty)
                        Text(
                          '${bank.city} • ${bank.branchCode}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: MyTheme.primaryColor,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Bank',
        ),
      ),
      body: BlocConsumer<BankTransactionBloc, BankTransactionState>(
        listener: (context, state) {
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
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your bank',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.isLoadingBanks
                          ? 'Loading banks...'
                          : 'Tap on any bank to continue',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Banks List
              Expanded(
                child: state.isLoadingBanks
                    ? _buildShimmerLoading()
                    : state.availableBanks.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        size: 64.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No Banks Available',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => context.read<BankTransactionBloc>().add(const FetchBanks()),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: () async {
                    context.read<BankTransactionBloc>().add(const FetchBanks());
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                    itemCount: state.availableBanks.length,
                    itemBuilder: (context, index) {
                      final bank = state.availableBanks[index];
                      return _buildBankCard(bank);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}