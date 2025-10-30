import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/fonts.dart';

class MyTheme {
  static ThemeData lightTheme(BuildContext context) => ThemeData(
        useMaterial3: true,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: backgroundColor,
        inputDecorationTheme: InputDecorationTheme(
          outlineBorder: const BorderSide(color: Colors.black),
          hintStyle: Font.montserratFont(
            color: Colors.black,
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
              Radius.circular(5.r),
            ),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.r)),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),

          /// Focused Border
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.r)),
            borderSide: const BorderSide(
              width: 1,
              color: Colors.black,
            ),
          ),

          /// Error Border
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.r)),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),

          /// Focused Error Border
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.r)),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
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
          bodyLarge:  Font.montserratFont(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: Font.montserratFont(
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          bodySmall: Font.montserratFont(
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          headlineLarge: Font.montserratFont(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 26.sp,
          ),
          headlineMedium: Font.montserratFont(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22.sp,
          ),
          headlineSmall: Font.montserratFont(
            fontSize: 20.sp,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          titleTextStyle: Font.montserratFont(
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
              Font.montserratFont(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
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
          hintStyle: Font.montserratFont(
            color: Colors.white,
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
          headlineSmall: Font.montserratFont(
            fontSize: 18.sp,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          // Specify the custom font for each style in the dark theme
          bodyLarge: Font.montserratFont(
              fontWeight: FontWeight.bold,
              color: Colors.white),
          bodyMedium: Font.montserratFont(
              fontWeight: FontWeight.normal,
              color: Colors.white),
          bodySmall: Font.montserratFont(
              fontWeight: FontWeight.normal,
              color: Colors.white),
          headlineLarge: Font.montserratFont(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 35.sp,
          ),
          headlineMedium: Font.montserratFont(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24.sp,
          ),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: MyTheme.darkBackgroundColor,
          titleTextStyle: Font.montserratFont(
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
              Font.montserratFont(
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
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: MyTheme.primaryColor,
          clipBehavior: Clip.antiAlias,
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