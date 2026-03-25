// import 'dart:ui';
//
// import 'package:clora_user/extensions/extension_util/int_extensions.dart';
// import 'package:clora_user/extensions/new_colors.dart';
// import 'package:clora_user/main.dart';
// import 'package:flutter/material.dart';
// import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
// import 'package:clora_user/screens/user/subscription_screen.dart';
// import 'package:clora_user/utils/dynamic_theme.dart';
//
// import '../../extensions/text_styles.dart';
//
// class BlurOverlayWithSubscribe extends StatelessWidget {
//   final double blurSigma;
//   final double opacity;
//   final double borderRadius;
//   final IconData icon;
//   final String buttonText;
//
//   const BlurOverlayWithSubscribe({
//     Key? key,
//     this.blurSigma = 5.0,
//     this.opacity = 0.2,
//     this.borderRadius = 16.0,
//     this.icon = Icons.lock,
//     this.buttonText = "Get Era Plus",
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned.fill(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Colors.white.withAlpha((255 * 0.4).toInt()),
//                 Colors.white.withAlpha((255 * 0.6).toInt()),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(borderRadius),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Animated lock icon
//                 PulsatingLockIcon(
//                   icon: icon,
//                   size: 20,
//                   color: ColorUtils.colorPrimary,
//                 ),
//                 const SizedBox(height: 20),
//                 // Text message
//                 Text(
//                   language.unlockPremiumFeatures,
//                   style: boldTextStyle(
//                     weight: FontWeight.w500,
//                     color: mainColor,
//                     size: 16,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 8.height,
//                 Text(
//                   language.subscribeToAccessExclusiveContentAndFeatures,
//                   textAlign: TextAlign.center,
//                   style: primaryTextStyle(
//                     size: 14,
//                     weight: FontWeight.w400,
//                     color: mainColor,
//                   ),
//                 ),
//                 16.height,
//                 // Subscribe button with shadow
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(30),
//                     boxShadow: [
//                       BoxShadow(
//                         color: ColorUtils.colorPrimary.withOpacity(0.3),
//                         blurRadius: 10,
//                         offset: Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       SubscriptionScreen().launch(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: ColorUtils.colorPrimary,
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 40,
//                         vertical: 8,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: Text(
//                       buttonText,
//                       style: primaryTextStyle(
//                         color: Colors.white,
//                         size: 16,
//                         weight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Add a pulsating animation to the lock icon
// class PulsatingLockIcon extends StatefulWidget {
//   final IconData icon;
//   final double size;
//   final Color color;
//
//   const PulsatingLockIcon({
//     Key? key,
//     required this.icon,
//     required this.size,
//     required this.color,
//   }) : super(key: key);
//
//   @override
//   _PulsatingLockIconState createState() => _PulsatingLockIconState();
// }
//
// class _PulsatingLockIconState extends State<PulsatingLockIcon>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _borderAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: Duration(milliseconds: 1000),
//       vsync: this,
//     )..repeat(reverse: true); // Loop the animation
//
//     // Scale animation for the icon
//     _scaleAnimation = Tween(begin: 0.9, end: 1.1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//
//     // Border animation for the circular border
//     _borderAnimation = Tween(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Container(
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: ColorUtils.colorPrimary.withAlpha((255 * 0.4).toInt()),
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: ColorUtils.colorPrimary.withAlpha((255 * 0.4).toInt()),
//               width: 1.5 * _borderAnimation.value, // Animate border width
//             ),
//           ),
//           child: ScaleTransition(
//             scale: _scaleAnimation,
//             child: Icon(
//               widget.icon,
//               size: widget.size,
//               color: widget.color,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
