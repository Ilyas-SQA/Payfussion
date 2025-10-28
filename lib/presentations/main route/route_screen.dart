import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/presentations/home/home_screen.dart';
import 'package:payfussion/logic/cubits/route_cubit/route_cubit.dart';
import 'package:payfussion/presentations/scan_to_pay/scan_to_pay_home.dart';
import 'package:payfussion/presentations/setting/setting_screen.dart';
import 'package:payfussion/presentations/transaction/transaction_home_screen.dart';
import '../widgets/route_widgets/custom_nav_bar.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final List<GlobalKey<State>> _screenKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];
  int _lastIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteCubit, int>(
      buildWhen: (int previous, int current) => previous != current,
      builder: (BuildContext context, int currentIndex) {
        /// Handle visibility changes when index changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleIndexChange(_lastIndex, currentIndex);
          _lastIndex = currentIndex;
        });

        /// Pre-define screens with keys
        final List<Widget> screens = [
          HomeScreen(key: _screenKeys[0]),
          ScanToPayHomeScreen(key: _screenKeys[1]),
          TransactionHomeScreen(key: _screenKeys[2]),
          SettingScreen(key: _screenKeys[3]),
        ];

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: currentIndex, children: screens),
          ),
          extendBody: true,
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: (int index) => context.read<RouteCubit>().changeScreen(index),
          ),
        );
      },
    );
  }

  void _handleIndexChange(int oldIndex, int newIndex) {
    /// Stop camera when leaving scan screen
    if (oldIndex == 1) {
      final GlobalKey<State<ScanToPayHomeScreen>> scanScreenKey = _screenKeys[1] as GlobalKey<State<ScanToPayHomeScreen>>;
      scanScreenKey.getVisibilityHandler()?.onScreenInvisible();
    }

    /// Start camera when entering scan screen
    if (newIndex == 1) {
      final GlobalKey<State<ScanToPayHomeScreen>> scanScreenKey = _screenKeys[1] as GlobalKey<State<ScanToPayHomeScreen>>;
      scanScreenKey.getVisibilityHandler()?.onScreenVisible();
    }
  }
}
