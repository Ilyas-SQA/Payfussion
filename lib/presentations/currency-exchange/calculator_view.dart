import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/presentations/currency-exchange/widget/calculator_widget.dart';
import 'package:payfussion/presentations/currency-exchange/widget/convert_widget.dart';

import '../../logic/blocs/calculator/calculator_bloc.dart';

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalculatorBloc(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Calculator"),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60.h),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8).r,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2A38),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    padding: EdgeInsets.all(10.r),
                    indicator: BoxDecoration(
                      color: MyTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: [
                      const Tab(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Calculator'),
                        ),
                      ),
                      const Tab(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Exchange Rate'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: const TabBarView(
            children: [
              CalculatorWidget(),
              ConvertWidget(),
            ],
          ),
        ),
      ),
    );
  }
}