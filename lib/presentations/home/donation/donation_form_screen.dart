import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/card_screen.dart';
import '../../../logic/blocs/donation/donation_bloc.dart';
import '../../../logic/blocs/donation/donation_event.dart';

class DonationFormScreen extends StatefulWidget {
  final String foundationName;
  final String category;
  final String description;
  final String website;

  const DonationFormScreen({
    super.key,
    required this.foundationName,
    required this.category,
    required this.description,
    required this.website,
  });

  @override
  State<DonationFormScreen> createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _proceedToCardSelection() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter donation amount'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Set donation data in bloc
    context.read<DonationBloc>().add(SetDonationData(
      foundationName: widget.foundationName,
      category: widget.category,
      description: widget.description,
      website: widget.website,
      amount: amount,
    ));

    // Navigate to card selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const CardsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Donation Amount"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Foundation Info Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    theme.primaryColor.withOpacity(0.1),
                    theme.primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.favorite,
                        size: 24.sp,
                        color: MyTheme.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.foundationName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor != Colors.white
                                ? Colors.white
                                : const Color(0xff2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow(Icons.category, widget.category, theme),
                  SizedBox(height: 8.h),
                  _buildInfoRow(Icons.description, widget.description, theme),
                  SizedBox(height: 8.h),
                  _buildInfoRow(Icons.language, widget.website, theme),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Amount Input
            Text(
              'Donation Amount',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor != Colors.white
                    ? Colors.white
                    : const Color(0xff2D3748),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: TextStyle(
                color: theme.primaryColor != Colors.white ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Enter amount (e.g., 50.00)',
                hintStyle: TextStyle(
                  color: theme.primaryColor != Colors.white
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey[400],
                ),
                prefixIcon: const Icon(Icons.attach_money, color: MyTheme.primaryColor),
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                  color: theme.primaryColor != Colors.white ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your donation will help make a difference',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor != Colors.white
                    ? Colors.white.withOpacity(0.6)
                    : Colors.grey[600],
                fontSize: 11.sp,
              ),
            ),

            SizedBox(height: 32.h),

            // Quick Amount Buttons
            Text(
              'Quick Select',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor != Colors.white
                    ? Colors.white
                    : const Color(0xff2D3748),
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [25, 50, 100, 250, 500, 1000].map((amount) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _amountController.text = amount.toString();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: MyTheme.primaryColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      color: _amountController.text == amount.toString()
                          ? MyTheme.primaryColor.withOpacity(0.1)
                          : null,
                    ),
                    child: Text(
                      '$amount',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor != Colors.white
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 40.h),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _proceedToCardSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.primaryColor,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'Continue to Card Selection',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 16.sp,
          color: MyTheme.primaryColor,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.primaryColor != Colors.white
                  ? Colors.white.withOpacity(0.8)
                  : const Color(0xff718096),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}