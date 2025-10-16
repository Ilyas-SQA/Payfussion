import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyTheme {
  static ThemeData lightTheme(BuildContext context) => ThemeData(
        useMaterial3: true,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: backgroundColor,
        inputDecorationTheme: InputDecorationTheme(
          outlineBorder: const BorderSide(color: Colors.black),
          hintStyle: TextStyle(
            color: const Color(0xff666666),
            fontFamily: 'Roboto',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.only(
            bottom: 48.h / 2,
            left: 19.w,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.r),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xffFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0.sp),
            ),
          ),
          elevation: 5,
        ),
        textTheme: Theme
            .of(context)
            .textTheme
            .copyWith(
          // Specify the custom font for each style in the dark theme
          bodyLarge: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Montserrat',
          ),
          bodyMedium: const TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.black,
            fontFamily: 'Montserrat',
          ),
          bodySmall: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 26.sp,
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22.sp,
            fontFamily: 'Montserrat',
          ),
          headlineSmall: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.normal,
            color: Colors.black,
            fontFamily: 'Montserrat',
          ),
        ),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          titleTextStyle: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold),
          shadowColor: Colors.transparent,
          iconTheme: const IconThemeData(color: MyTheme.primaryColor),
        ),
        dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        fontFamilyFallback: const ['Montserrat'],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
              TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            backgroundColor: WidgetStateProperty.all(
              MyTheme.primaryColor,
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0.r),
              ),
            ),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 20,
          backgroundColor: Colors.transparent,
          selectedItemColor: MyTheme.primaryColor,
          unselectedItemColor: Colors.grey[500],
        ),
        brightness: Brightness.light,
        primaryColor: Colors.white,
        secondaryHeaderColor: Colors.black,
        canvasColor: backgroundColor,
        colorScheme: const ColorScheme(
          primaryContainer: Colors.white,
          onSecondary: backgroundColor,
          onPrimary: Colors.black,
          onSurface: Colors.black,
          secondary: backgroundColor,
          surface: backgroundColor,
          brightness: Brightness.light,
          error: Colors.red,
          onError: Colors.red,
          primary: Colors.white,
        ),
      );

  static ThemeData darkTheme(BuildContext context) => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: MyTheme.darkBackgroundColor,
        inputDecorationTheme: InputDecorationTheme(
          outlineBorder: const BorderSide(color: Colors.black),
          hintStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.only(
            bottom: 48.h / 2,
            left: 19.w,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.r),
            ),
          ),
        ),
        textTheme: Theme
            .of(context)
            .textTheme
            .copyWith(
          headlineSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18.sp,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          // Specify the custom font for each style in the dark theme
          bodyLarge: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.white),
          bodyMedium: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.normal,
              color: Colors.white),
          bodySmall: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.normal,
              color: Colors.white),
          headlineLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 35.sp,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24.sp,
          ),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: MyTheme.darkBackgroundColor,
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: MyTheme.primaryColor),
          scrolledUnderElevation: 0,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
              TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: WidgetStateProperty.all(MyTheme.primaryColor),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0.r),
              ),
            ),
          ),
        ),

        dialogTheme: const DialogThemeData(backgroundColor: Colors.black),
        secondaryHeaderColor: Colors.white,
        brightness: Brightness.dark,
        cardTheme: CardThemeData(
          color: const Color(0xff525E6C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0.sp),
            ),
          ),
        ),
        fontFamilyFallback: const ['Montserrat'],
        //to be implemented
        primaryColor: const Color(0xff666666),
        canvasColor: backgroundColor,
        iconTheme: const IconThemeData(color: MyTheme.primaryColor),
        colorScheme: const ColorScheme(
          onSecondary: backgroundColor,
          onPrimary: Colors.white,
          onSurface: Colors.white,
          secondary: MyTheme.darkBackgroundColor,
          surface: MyTheme.darkBackgroundColor,
          brightness: Brightness.dark,
          error: Colors.red,
          onError: Colors.red,
          primary: Colors.white70,
        ),
      );

  static const Color backgroundColor = Color(0xffF9F8F4);
  static const Color darkBackgroundColor = Color(0xFF323C46);
  static const Color primaryColor = Color(0xFF55d2df);
  static const Color secondaryColor = Color(0xFF27ad60);
  static const Color _warningColor = Color(0xFFF2C94C); // For specific warnings or info
  static const Color _errorColor = Color(0xFFEB5757);
  static const List<Color> listColor = [
  Color(0xFF55d2df),
  Color(0xFF80e160),
  ];
}