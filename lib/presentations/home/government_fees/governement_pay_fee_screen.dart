import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/card_screen.dart';
import '../../../logic/blocs/governement_fee/governement_fee_bloc.dart';
import '../../../logic/blocs/governement_fee/governement_fee_event.dart';
import '../../widgets/auth_widgets/credential_text_field.dart';
import 'government_fees_screen.dart';

class GovernementPayFeeScreen extends StatefulWidget {
  final GovtService service;

  const GovernementPayFeeScreen({Key? key, required this.service}) : super(key: key);

  @override
  State<GovernementPayFeeScreen> createState() => _GovernementPayFeeScreenState();
}

class _GovernementPayFeeScreenState extends State<GovernementPayFeeScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_updateButtonState);
    _amountController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _inputController.text.isNotEmpty &&
          _amountController.text.isNotEmpty;
    });
  }

  void _proceedToCardSelection() {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter ${widget.service.inputLabel}')),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount')),
      );
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Set government fee data in bloc
    context.read<GovernmentFeeBloc>().add(SetGovernmentFeeData(
      serviceName: widget.service.name,
      agency: widget.service.agency,
      inputLabel: widget.service.inputLabel,
      inputValue: _inputController.text,
      amount: amount,
    ));

    // Navigate to card selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CardsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: MyTheme.primaryColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Text(
                    widget.service.emoji,
                    style: TextStyle(fontSize: 40.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.service.agency,
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Input Label
            Text(
              widget.service.inputLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Input Field
            Row(
              children: [
                Expanded(
                  child: AppTextFormField(
                    controller: _inputController,
                    keyboardType: TextInputType.text,
                    helpText: widget.service.inputHint,
                  ),
                ),
                if (widget.service.hasInfoIcon)
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      if (widget.service.infoText != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(widget.service.infoText!),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),

            // Info text if available
            if (widget.service.hasInfoIcon && widget.service.infoText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.service.infoText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),

            SizedBox(height: 24.h),

            // Amount Label
            const Text(
              'Fee Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Amount Input Field
            AppTextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              helpText: 'Enter amount (USD)',
              prefixIcon: Icon(Icons.attach_money),
            ),

            const Spacer(),

            // Next Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isButtonEnabled ? _proceedToCardSelection : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled
                      ? MyTheme.primaryColor
                      : Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue to Card Selection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}