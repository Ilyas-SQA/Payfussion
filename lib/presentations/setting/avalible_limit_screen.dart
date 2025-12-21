import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../data/models/transaction_limit/transaction_limit_model.dart';
import '../../logic/blocs/transaction_limit/transaction_limit_bloc.dart';
import '../../logic/blocs/transaction_limit/transaction_limit_event.dart';
import '../../logic/blocs/transaction_limit/transaction_limit_state.dart';

class LimitSettingContainer extends StatelessWidget {
  final String userId;

  const LimitSettingContainer({
    super.key,
    required this.userId,
  });

  void _showLimitOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) => BlocProvider.value(
        value: context.read<LimitBloc>(),
        child: _LimitOptionsBottomSheet(userId: userId),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LimitBloc, LimitState>(
      builder: (BuildContext context, LimitState state) {
        if (state is LimitLoading) {
          return _buildLoadingContainer(context);
        }

        if (state is LimitError) {
          return _buildErrorContainer(context, state.message);
        }

        if (state is LimitLoaded) {
          return GestureDetector(
            onTap: () => _showLimitOptions(context),
            child: _buildLimitContainer(context, state.limitData),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildLoadingContainer(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorContainer(BuildContext context, String message) {
    return Container(
      height: 170,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              'Error loading limit',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitContainer(
      BuildContext context,
      TransactionLimitData limitData,
      ) {
    return Container(
      height: 190,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction Limit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              // Badge showing if custom limit is set
              if (limitData.hasCustomLimit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: MyTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MyTheme.primaryColor, width: 1),
                  ),
                  child: const Text(
                    'Custom Limit',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Text(
                    'Default Limit',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Limit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${_formatAmount(limitData.totalLimit)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${_formatAmount(limitData.remainingAmount)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: limitData.usagePercentage > 0.8 ? Colors.red : MyTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Used: Rs. ${_formatAmount(limitData.usedAmount)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${(limitData.usagePercentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: MyTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: limitData.usagePercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: limitData.usagePercentage > 0.8
                            ? [Colors.red, Colors.red[700]!]
                            : limitData.usagePercentage > 0.5
                            ? [Colors.orange, Colors.orange[700]!]
                            : [Colors.green, Colors.green[700]!],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Your Rs. ${(limitData.totalLimit / 1000).toStringAsFixed(0)}k ${limitData.period.toLowerCase()} limit resets on ${_getResetDateText(limitData.resetDate)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '${limitData.utilityBills} bills',
                style: const TextStyle(
                  fontSize: 11,
                  color: MyTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  String _getResetDateText(DateTime? resetDate) {
    if (resetDate == null) return '1st of next month';
    return '${resetDate.day} ${_getMonthName(resetDate.month)}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// Bottom Sheet Widget
class _LimitOptionsBottomSheet extends StatelessWidget {
  final String userId;

  const _LimitOptionsBottomSheet({required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LimitBloc, LimitState>(
      builder: (BuildContext context, LimitState state) {
        if (state is! LimitLoaded) return const SizedBox();
        final LimitOption tempSelected = state.tempSelectedLimit ?? state.availableLimits.firstWhere((opt) =>
        opt.amount == state.limitData.totalLimit && opt.utilityBills == state.limitData.utilityBills,
          orElse: () => state.availableLimits.isNotEmpty ? state.availableLimits[0] : LimitOption(amount: 250000, utilityBills: 5),
        );
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Column(
            children: [
              _buildHeader(context, state.limitData),
              Expanded(
                child: _buildOptionsList(
                  context,
                  state.availableLimits,
                  tempSelected,
                ),
              ),
              _buildConfirmButton(context, tempSelected),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, TransactionLimitData currentLimit) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Limits',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Current: Rs. ${_formatAmount(currentLimit.totalLimit)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: MyTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );}

  Widget _buildOptionsList(
      BuildContext context,
      List<LimitOption> options,
      LimitOption selected,
      ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selected.amount == option.amount &&
            selected.utilityBills == option.utilityBills;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? MyTheme.primaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: InkWell(
            onTap: () {
              context.read<LimitBloc>().add(SelectTempLimitEvent(option));
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildRadioButton(isSelected),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'PKR ${_formatAmount(option.amount)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? MyTheme.primaryColor : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${option.utilityBills} bills',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${option.period} limit',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: MyTheme.primaryColor,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadioButton(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? MyTheme.primaryColor : Colors.grey[400]!,
          width: 2,
        ),
        color: isSelected ? MyTheme.primaryColor : Colors.transparent,
      ),
      child: isSelected
          ? const Center(
        child: Icon(
          Icons.circle,
          size: 12,
          color: Colors.white,
        ),
      )
          : null,
    );
  }

  Widget _buildConfirmButton(BuildContext context, LimitOption selected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            context.read<LimitBloc>().add(
              UpdateLimitEvent(
                userId: userId,
                selectedLimit: selected,
              ),
            );
            Navigator.pop(context);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Limit updated to Rs. ${_formatAmount(selected.amount)}',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: MyTheme.primaryColor,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Confirm Selection',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}