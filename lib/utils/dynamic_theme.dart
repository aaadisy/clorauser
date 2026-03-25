import 'dart:ui'; // Required for BackdropFilter
import 'package:flutter/material.dart';

class ColorUtils {
  static Color? themeColor;
  static Color? _colorPrimary;
  static Color? _colorPrimaryLight;
  static Color? _borderColor;
  static Color? _bottomNavigationColor;
  static Color? _scaffoldSecondaryDark;
  static Color? _scaffoldColorDark;
  static Color? _scaffoldColorLight;
  static Color? _appButtonColorDark;
  static Color? _dividerColor;
  static Color? _cardDarkColor;
  
  // New Theme Colors
  static const Color PRIMARY_PINK = Color(0xFFF6A9B3); // Soft Pastel Pink
  static const Color PRIMARY_CREAM = Color(0xFFF7E9DA); // Creamy Off-White
  static const Color HIGHLIGHT_PINK = Color(0xFFFBD0D6); // Subtle Light Pink
  static const Color HIGHLIGHT_IVORY = Color(0xFFFFF3E8); // Warm Ivory Transition

  // Root Background Gradient Definition (for use in MaterialApp/Scaffold background)
  static const LinearGradient ROOT_BACKGROUND_GRADIENT = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      PRIMARY_PINK,       // #F6A9B3
      HIGHLIGHT_PINK,     // #FBD0D6
      HIGHLIGHT_IVORY,    // #FFF3E8
      PRIMARY_CREAM,      // #F7E9DA
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  ColorUtils({String primaryHex = "#F44087"}) {
    themeColor = PRIMARY_PINK;
    _colorPrimary = PRIMARY_PINK;
    _initializeColors();
  }
  
  static void _initializeColors() {
    // Keeping colors muted/pastel derived, but relying on GlassContainer for the true white/blur effect.
    _colorPrimaryLight = HIGHLIGHT_IVORY.withOpacity(0.7); 
    _borderColor = PRIMARY_PINK.withOpacity(0.5); 
    _scaffoldSecondaryDark = HIGHLIGHT_PINK.withOpacity(0.4);
    _scaffoldColorDark = Color(0xFF30282A); // Muted dark base
    _scaffoldColorLight = PRIMARY_CREAM; // Base for light mode background
    _appButtonColorDark = PRIMARY_PINK.withOpacity(0.8); 
    _dividerColor = PRIMARY_PINK.withOpacity(0.3); 
    _cardDarkColor = Color(0xFF403537); 
    _bottomNavigationColor = bottomNavigationBarColor(PRIMARY_PINK);
  }

  static void updateColors(String color) {
    themeColor = colorFromHex(color);
    _colorPrimary = colorFromHex(color);
    _initializeColors(); 
  }

  static Color colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static Color bottomNavigationBarColor(Color color) {
    double lightenPercent = 10.0; 
    Color hoverColor = lightenColor(color, lightenPercent);
    return hoverColor;
  }

  static Color lightenColor(Color color, double percent) {
    final p = percent / 100;
    final r = (color.r + ((255 - color.r) * p)).round();
    final g = (color.g + ((255 - color.g) * p)).round();
    final b = (color.b + ((255 - color.b) * p)).round();

    return Color.fromRGBO(r, g, b, 1.0);
  }

  static Color get colorPrimary => _colorPrimary ?? PRIMARY_PINK;
  static Color get colorPrimaryLight => _colorPrimaryLight ?? HIGHLIGHT_IVORY.withOpacity(0.7);
  static Color get borderColor => _borderColor ?? PRIMARY_PINK.withOpacity(0.5);
  static Color get bottomNavigationColor => _bottomNavigationColor ?? PRIMARY_PINK;
  static Color get scaffoldSecondaryDark => _scaffoldSecondaryDark ?? HIGHLIGHT_PINK.withOpacity(0.3);
  static Color get scaffoldColorDark => _scaffoldColorDark ?? Color(0xFF30282A);
  static Color get scaffoldColorLight => _scaffoldColorLight ?? PRIMARY_CREAM;
  static Color get appButtonColorDark => _appButtonColorDark ?? HIGHLIGHT_PINK.withOpacity(0.8);
  static Color get dividerColor => _dividerColor ?? PRIMARY_PINK.withOpacity(0.3);
  static Color get cardDarkColor => _cardDarkColor ?? Color(0xFF403537);
}

// --- Glassmorphism Reusable Widget (Hardened for 3D Effect) ---
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blurValue;
  final Color baseColor; // 2️⃣ True Glass Color: White with high opacity for blur to show
  final BoxBorder? border;
  final List<BoxShadow>? shadows;
  final AlignmentGeometry? alignment;
  final EdgeInsets? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 28.0, // 4️⃣ Increased Radius
    this.blurValue = 25.0, // 1️⃣ Increased Blur (Stronger)
    this.baseColor = const Color(0x28FFFFFF), // 2️⃣ True Glass Color: White at ~0.16 opacity (closer to 0.15)
    this.border,
    this.shadows,
    this.alignment,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // 3️⃣ Dual 3D Shadows
    final softShadow = shadows ?? [
      BoxShadow(
        color: ColorUtils.PRIMARY_PINK.withOpacity(0.5),
        blurRadius: 40,
        offset: Offset(0, 20),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.3),
        blurRadius: 10,
        offset: Offset(-5, -5),
      ),
    ];
    
    // Border using consistent light color
    final glassBorder = border ?? Border.all(
      color: Colors.white.withOpacity(0.3), // Slightly stronger white border
      width: 1.0,
    );

    return Container(
      width: width,
      height: height,
      alignment: alignment,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: glassBorder,
        boxShadow: softShadow, // Apply dual shadows
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}