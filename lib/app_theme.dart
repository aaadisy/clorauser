import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../extensions/colors.dart';
import '../../extensions/decorations.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
      useMaterial3: false,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      scaffoldBackgroundColor: whiteColor,
      primaryColor: primaryColor,
      iconTheme: IconThemeData(color: Colors.black),
      dividerColor: viewLineColor,
      colorScheme: ColorScheme(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onError: Colors.redAccent,
        brightness: Brightness.light,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: radius(20),
            side: BorderSide(width: 1, color: primaryColor)),
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.all(primaryColor),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ));

  // static final ThemeData darkTheme = ThemeData(
  //   useMaterial3: false,
  //   splashColor: Colors.transparent,
  //   hoverColor: Colors.transparent,
  //   scaffoldBackgroundColor: scaffoldBackgroundColor,
  //   iconTheme: IconThemeData(color: Colors.white),
  //   colorScheme: ColorScheme(
  //     primary: primaryColor,
  //     secondary: primaryColor,
  //     surface: Colors.black,
  //     background: Colors.black,
  //     error: Colors.red,
  //     onPrimary: Colors.black,
  //     onSecondary: Colors.white,
  //     onSurface: Colors.white,
  //     onBackground: Colors.white,
  //     onError: Colors.redAccent,
  //     brightness: Brightness.dark,
  //   ),
  //   dividerColor: Colors.white24,
  //   textTheme: GoogleFonts.poppinsTextTheme(),
  //   checkboxTheme: CheckboxThemeData(
  //     shape: RoundedRectangleBorder(borderRadius: radius(20), side: BorderSide(width: 1, color: primaryColor)),
  //     checkColor: MaterialStateProperty.all(Colors.white),
  //     fillColor: MaterialStateProperty.all(primaryColor),
  //     materialTapTargetSize: MaterialTapTargetSize.padded,
  //   ),
  //   pageTransitionsTheme: PageTransitionsTheme(
  //     builders: <TargetPlatform, PageTransitionsBuilder>{
  //       TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
  //       TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
  //       TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  //     },
  //   ),
  // );
}
