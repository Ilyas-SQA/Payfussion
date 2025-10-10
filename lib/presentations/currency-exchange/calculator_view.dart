import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          body: Column(
            children: [
              50.verticalSpace,
              TabBar(
                dividerColor: Colors.transparent,
                indicatorWeight: 0.1,
                indicatorColor: Colors.blue,
                tabAlignment: TabAlignment.center,
                unselectedLabelColor: Colors.grey, // Changed from Colors.white to Colors.grey
                labelColor: Colors.blue,
                labelStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.normal,
                ),
                tabs: const <Widget>[
                  Tab(text: 'Calculator'),
                  Tab(text: 'Exchange Rate'),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    CalculatorWidget(),
                    ConvertWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}