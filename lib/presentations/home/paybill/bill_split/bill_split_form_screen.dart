import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/card_screen.dart';
import '../../../../logic/blocs/pay_bill/bill_split/bill_split_bloc.dart';
import '../../../../logic/blocs/pay_bill/bill_split/bill_split_event.dart';

class BillSplitFormScreen extends StatefulWidget {
  const BillSplitFormScreen({super.key});

  @override
  State<BillSplitFormScreen> createState() => _BillSplitFormScreenState();
}

class _BillSplitFormScreenState extends State<BillSplitFormScreen>
    with TickerProviderStateMixin {
  final TextEditingController _billNameController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _numberOfPeopleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _splitType = 'equal'; // 'equal' or 'custom'
  List<TextEditingController> _participantControllers = <TextEditingController>[];
  List<TextEditingController> _customAmountControllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _numberOfPeopleController.addListener(_updateParticipants);
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  void _updateParticipants() {
    final int? count = int.tryParse(_numberOfPeopleController.text);
    if (count != null && count > 0 && count <= 20) {
      setState(() {
        // Clear existing controllers
        for (TextEditingController controller in _participantControllers) {
          controller.dispose();
        }
        for (TextEditingController controller in _customAmountControllers) {
          controller.dispose();
        }

        // Create new controllers
        _participantControllers = List.generate(
          count,
              (int index) => TextEditingController(text: 'Person ${index + 1}'),
        );
        _customAmountControllers = List.generate(
          count,
              (int index) => TextEditingController(),
        );
      });
    }
  }

  @override
  void dispose() {
    _billNameController.dispose();
    _totalAmountController.dispose();
    _numberOfPeopleController.dispose();
    _fadeController.dispose();
    for (TextEditingController controller in _participantControllers) {
      controller.dispose();
    }
    for (TextEditingController controller in _customAmountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _proceedToCardSelection() {
    if (_formKey.currentState!.validate()) {
      if (_billNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter bill name')),
        );
        return;
      }

      if (_totalAmountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter total amount')),
        );
        return;
      }

      if (_participantControllers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please specify number of people')),
        );
        return;
      }

      final double totalAmount = double.parse(_totalAmountController.text);
      final List<String> participantNames = _participantControllers
          .map((TextEditingController controller) => controller.text)
          .toList();

      Map<String, double>? customAmounts;
      if (_splitType == 'custom') {
        customAmounts = <String, double>{};
        for (int i = 0; i < _participantControllers.length; i++) {
          final double amount = double.tryParse(_customAmountControllers[i].text) ?? 0.0;
          customAmounts[participantNames[i]] = amount;
        }

        // Validate custom amounts sum
        final double totalCustom = customAmounts.values.fold(0.0, (double a, double b) => a + b);
        if ((totalCustom - totalAmount).abs() > 0.01) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Custom amounts must sum to \$${totalAmount.toStringAsFixed(2)}. Current: \$${totalCustom.toStringAsFixed(2)}'
              ),
            ),
          );
          return;
        }
      }

      // Set bill split data in bloc
      context.read<BillSplitBloc>().add(SetBillSplitData(
        billName: _billNameController.text,
        totalAmount: totalAmount,
        numberOfPeople: _participantControllers.length,
        participantNames: participantNames,
        splitType: _splitType,
        customAmounts: customAmounts,
      ));

      // Navigate to card selection
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const CardsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Split Bill',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildBillNameInput(theme),
                SizedBox(height: 24.h),
                _buildTotalAmountInput(theme),
                SizedBox(height: 24.h),
                _buildNumberOfPeopleInput(theme),
                SizedBox(height: 24.h),
                _buildSplitTypeSelector(theme),
                SizedBox(height: 24.h),
                if (_participantControllers.isNotEmpty) ...<Widget>[
                  _buildParticipantsSection(theme),
                  SizedBox(height: 32.h),
                ],
                _buildContinueButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillNameInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Bill Name',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _billNameController,
          decoration: InputDecoration(
            hintText: 'e.g., Dinner at Restaurant',
            prefixIcon: const Icon(Icons.receipt_long, color: MyTheme.primaryColor),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter bill name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTotalAmountInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Total Amount',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _totalAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: 'Enter total bill amount',
            prefixIcon: const Icon(Icons.attach_money, color: MyTheme.primaryColor),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: MyTheme.primaryColor, width: 2),
            ),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter total amount';
            }
            final double? amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNumberOfPeopleInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Number of People',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _numberOfPeopleController,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          decoration: InputDecoration(
            hintText: 'How many people?',
            prefixIcon: const Icon(Icons.people, color: MyTheme.primaryColor),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: MyTheme.primaryColor, width: 2),
            ),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter number of people';
            }
            final int? count = int.tryParse(value);
            if (count == null || count < 2) {
              return 'Minimum 2 people required';
            }
            if (count > 20) {
              return 'Maximum 20 people allowed';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSplitTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Split Type',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _splitType = 'equal'),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _splitType == 'equal'
                        ? MyTheme.primaryColor
                        : theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _splitType == 'equal'
                          ? MyTheme.primaryColor
                          : Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.calculate,
                        color: _splitType == 'equal'
                            ? Colors.white
                            : MyTheme.primaryColor,
                        size: 32.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Equal Split',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _splitType == 'equal'
                              ? Colors.white
                              : (theme.primaryColor != Colors.white
                              ? Colors.white
                              : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _splitType = 'custom'),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _splitType == 'custom'
                        ? MyTheme.primaryColor
                        : theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _splitType == 'custom'
                          ? MyTheme.primaryColor
                          : Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.edit,
                        color: _splitType == 'custom'
                            ? Colors.white
                            : MyTheme.primaryColor,
                        size: 32.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Custom Split',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _splitType == 'custom'
                              ? Colors.white
                              : (theme.primaryColor != Colors.white
                              ? Colors.white
                              : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantsSection(ThemeData theme) {
    final double totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    final double amountPerPerson = _participantControllers.isNotEmpty
        ? totalAmount / _participantControllers.length
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Participants',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        if (_splitType == 'equal')
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'Each person pays: \$${amountPerPerson.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14.sp,
                color: MyTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _participantControllers.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _participantControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Person ${index + 1}',
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: MyTheme.primaryColor, width: 2),
                        ),
                      ),
                    ),
                  ),
                  if (_splitType == 'custom') ...<Widget>[
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: _customAmountControllers[index],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: '\$',
                          filled: true,
                          fillColor: theme.scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: MyTheme.primaryColor, width: 2),
                          ),
                        ),
                        validator: (String? value) {
                          if (_splitType == 'custom') {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final double? amount = double.tryParse(value);
                            if (amount == null || amount < 0) {
                              return 'Invalid';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ] else
                    Padding(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Text(
                        '\$${amountPerPerson.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: MyTheme.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContinueButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _proceedToCardSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: MyTheme.primaryColor,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
        ),
        child: Text(
          'Continue to Card Selection',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}