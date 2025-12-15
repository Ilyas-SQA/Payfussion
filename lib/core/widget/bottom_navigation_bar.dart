import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/presentations/home/paybill/electricity_bill/electricity_bill_form_screen.dart';
import 'package:payfussion/presentations/setting/setting_screen.dart';
import 'package:payfussion/presentations/transaction/transaction_home_screen.dart';

import '../../presentations/home/home/home_screen.dart';
import '../../presentations/scan_to_pay/scan_to_pay_home.dart';
import '../constants/fonts.dart';


class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({super.key});

  @override
  State<BottomNavigationBarScreen> createState() => _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {

  List<Widget> pages = [
    const HomeScreen(),
    const ScanToPayHomeScreen(),
    const TransactionHomeScreen(),
    const SettingScreen(),
  ];

  int currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    print("Build Bottom Navigation Bar");
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: MyTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        currentIndex: currentIndex,
        selectedLabelStyle: Font.montserratFont(
          fontSize: 12,
        ),
        unselectedLabelStyle: Font.montserratFont(
        fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        onTap: (int index){
          setState(() {
            currentIndex = index;
          });
          print("Selected Index: $index");
        },
        items: [
          BottomNavigationBarItem(

            icon: SvgPicture.asset(
              "assets/images/bottom_navigation_bar/home.svg",
              height: 25,width: 25,
              color: currentIndex == 0 ? MyTheme.primaryColor : Colors.grey,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottom_navigation_bar/QR_icon.svg",
              height: 25,width: 25,
              color: currentIndex == 1 ? MyTheme.primaryColor : Colors.grey,
            ),
            label: "QR Scan",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottom_navigation_bar/arrow.svg",
              height: 25,width: 25,
              color: currentIndex == 2 ? MyTheme.primaryColor : Colors.grey,
            ),
            label: "Transaction",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottom_navigation_bar/Menu.svg",
              height: 25,width: 25,
              color: currentIndex == 3 ? MyTheme.primaryColor : Colors.grey,
            ),
            label: "More",
          ),
        ],
      ),
    );
  }
}
