import 'package:flutter/material.dart';
import '../../extensions/text_styles.dart';
import '../../utils/app_images.dart';

class CommonActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final double? width; // ✅ nullable now
  final bool isVisible;
  final VoidCallback onTap;

  const CommonActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
    this.backgroundColor = const Color(0xFF6200EE),
    this.textColor = Colors.white,
    this.width,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              minHeight: 44,
              minWidth: width ?? 120,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // ✅ IMPORTANT
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// ICON
                Image.asset(
                  ic_add_icon,
                  width: 20,
                  height: 20,
                  color: iconColor,
                ),

                const SizedBox(width: 8),

                /// TEXT (Flexible prevents overflow)
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: boldTextStyle(
                      color: textColor,
                      size: 15,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
