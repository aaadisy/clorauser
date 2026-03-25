import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';
import 'package:pdf/widgets.dart' as pw;

/// Styles

// Bold Text Style
TextStyle boldTextStyle({
  int? size,
  Color? color,
  FontWeight? weight,
  String? fontFamily,
  double? letterSpacing,
  FontStyle? fontStyle,
  double? wordSpacing,
  TextDecoration? decoration,
  TextDecorationStyle? textDecorationStyle,
  TextBaseline? textBaseline,
  Color? decorationColor,
  Color? backgroundColor,
  double? height,
  List<Shadow>? shadows,
  bool? isHeader = false,
}) {
  return GoogleFonts.poppins(
    fontSize: size != null ? size.toDouble() : textBoldSizeGlobal,
    color: color ?? textPrimaryColorGlobal,
    fontWeight: weight ?? FontWeight.normal,
    shadows: shadows,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
    decoration: decoration,
    decorationStyle: textDecorationStyle,
    decorationColor: decorationColor,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    backgroundColor: backgroundColor,
    height: height,
  );
}

// Primary Text Style
TextStyle primaryTextStyle({
  int? size,
  Color? color,
  FontWeight? weight,
  String? fontFamily,
  double? letterSpacing,
  FontStyle? fontStyle,
  double? wordSpacing,
  TextDecoration? decoration,
  TextDecorationStyle? textDecorationStyle,
  TextBaseline? textBaseline,
  Color? decorationColor,
  Color? backgroundColor,
  double? height,
}) {
  return GoogleFonts.nunito(
    fontSize: size != null ? size.toDouble() : textPrimarySizeGlobal,
    color: color ?? textPrimaryColorGlobal,
    fontWeight: weight ?? fontWeightPrimaryGlobal,
    // fontFamily: fontFamily ?? fontFamilyPrimaryGlobal,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
    decoration: decoration,
    decorationStyle: textDecorationStyle,
    decorationColor: decorationColor,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    backgroundColor: backgroundColor,
    height: height,
  );
}

// Secondary Text Style
TextStyle secondaryTextStyle({
  int? size,
  Color? color,
  FontWeight? weight,
  String? fontFamily,
  double? letterSpacing,
  FontStyle? fontStyle,
  double? wordSpacing,
  TextDecoration? decoration,
  TextDecorationStyle? textDecorationStyle,
  TextBaseline? textBaseline,
  Color? decorationColor,
  Color? backgroundColor,
  double? height,
}) {
  return GoogleFonts.poppins(
    fontSize: size != null ? size.toDouble() : textSecondarySizeGlobal,
    color: color ?? textSecondaryColorGlobal,
    fontWeight: weight ?? fontWeightSecondaryGlobal,
    // fontFamily: fontFamily ?? fontFamilySecondaryGlobal,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
    decoration: decoration,
    decorationStyle: textDecorationStyle,
    decorationColor: decorationColor,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    backgroundColor: backgroundColor,
    height: height,
  );
}

// Create Rich Text
@Deprecated('Use RichTextWidget instead')
RichText createRichText({
  required List<TextSpan> list,
  TextOverflow overflow = TextOverflow.clip,
  int? maxLines,
  TextAlign textAlign = TextAlign.left,
  TextDirection? textDirection,
  StrutStyle? strutStyle,
}) {
  return RichText(
    text: TextSpan(children: list),
    overflow: overflow,
    maxLines: maxLines,
    textAlign: textAlign,
    textDirection: textDirection,
    strutStyle: strutStyle,
  );
}

class PdfFontHelper {
  static pw.Font? _defaultFont;
  static pw.Font? _arabicFont;
  static pw.Font? _hindiFont;

  static Future<void> loadFonts() async {
    _defaultFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    _arabicFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'));
    _hindiFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf'));
  }

  static pw.Font? getFontForLanguage(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ar':
        return _arabicFont ?? _defaultFont;
      case 'hi':
        return _hindiFont ?? _defaultFont;
      default:
        return _defaultFont;
    }
  }

  static pw.TextStyle getTextStyleForCountry(String countryCode,
      {double fontSize = 12}) {
    return pw.TextStyle(
      font: getFontForLanguage(countryCode),
      fontSize: fontSize,
    );
  }

  static bool isRtlLanguage(String languageCode) {
    const rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(languageCode.toLowerCase());
  }
}
