import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async'; // Added for Future/Stream management

import 'package:clora_user/screens/user/user_dashboard_screen.dart'; // Import Dashboard
import 'package:clora_user/screens/user/sign_in_screen.dart'; // Import Sign In
import 'package:clora_user/screens/onboarding/fu_style_question_screen.dart'; // Import for new users
import 'package:clora_user/extensions/shared_pref.dart'; // For async storage helpers like getStringAsync
import 'package:clora_user/utils/app_constants.dart'; // For IS_LOGIN and TOKEN constants
import 'package:clora_user/utils/app_common.dart'; // For getBoolAsync and getStringAsync if not in shared_pref
import 'package:clora_user/extensions/extension_util/widget_extensions.dart'; 


// Global Stubs REMOVED - Relying on global instances/store imports already handled in main.dart or their respective files.

Widget Loader() => const Center(child: CircularProgressIndicator());

void main() {
  runApp(const CloraAppNew());
}

class CloraAppNew extends StatelessWidget {
  const CloraAppNew({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clora - New Splash',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFC0CB)),
        useMaterial3: true,
      ),
      home: const NewSplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NewSplashScreen extends StatefulWidget {
  const NewSplashScreen({super.key});

  @override
  State<NewSplashScreen> createState() => _NewSplashScreenState();
}

class _NewSplashScreenState extends State<NewSplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  static const Duration _totalDuration = Duration(seconds: 8);

  late Animation<double> _fallAnimation;
  late Animation<double> _convergeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _pulseAnimation;
  
  late List<CloraElementNew> elements;

  final String mainLogoPath = 'assets/ic_logo_gray.png';
  final List<String> elementAssetPaths = [
    'assets/clorasplash/hormonal.png',
    'assets/clorasplash/menopause.png',
    'assets/clorasplash/menstruation.png',
    'assets/clorasplash/pcos.png',
    'assets/clorasplash/pms.png',
    'assets/clorasplash/pregnancy.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );

    _fallAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutSine),
    );

    _convergeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.8, curve: Curves.easeInOutCubic),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 0.9, curve: Curves.elasticOut),
      ),
    );
    
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 0.83, curve: Curves.easeIn),
      ),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.03), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.9, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    final Random rand = Random();
    
    elements = List.generate(elementAssetPaths.length, (index) {
      return CloraElementNew(
        assetPath: elementAssetPaths[index],
        startX: (index / (elementAssetPaths.length - 1)) * 1.0 - 0.5, 
        startY: -1.2 - rand.nextDouble() * 0.4,
        floatXOffset: rand.nextDouble() * 0.2 - 0.1,
        rotationSpeed: rand.nextDouble() * 1.5 + 0.5, 
        size: 90, 
        delay: rand.nextDouble() * 0.1,
      );
    });

    _controller.forward();
    
    // Add listener to navigate after animation completes
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await _checkSessionAndNavigate(context);
      }
    });
  }

  Future<void> _checkSessionAndNavigate(BuildContext context) async {
    // Check for session status using keys from app_constants.dart
    final bool? isLoggedIn = await getBoolAsync(IS_LOGIN);
    final String? token = await getStringAsync(TOKEN);
    final bool? profileCompleted = await getBoolAsync('profile_completed'); // Assuming profile status is also stored if needed for initial check

    // For safety, check if token exists AND IS_LOGIN is true
    final isUserLoggedIn = isLoggedIn == true && token != null && token.isNotEmpty;
    
    if (isUserLoggedIn) {
      // If logged in, check profile completion status (using '1' for true/completed like in auth_flow_service.dart)
      final String? profileStatus = await getStringAsync('profile_completed'); // Using getStringAsync if profile_completed is stored as string '0' or '1'

      if (profileStatus == '1') {
        // 👉 COMPLETED USER: Redirect to DashboardScreen
        // Use isNewTask: true to ensure it replaces the splash screen stack
        // DashboardScreen(currentIndex: 0).launch(context, isNewTask: true); 
        // Since launch is not available here, use Navigator.pushReplacement
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardScreen(currentIndex: 0),
            ),
          );
      } else {
        // 👉 NEW/INCOMPLETE USER or token is valid but profile is incomplete: Redirect to Onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AiOnboardingScreen(isFromLogin: true), // Reusing logic from auth_flow_service.dart for incomplete user
          ),
        );
      }
    } else {
      // 👉 NOT LOGGED IN: Redirect to Sign In Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserSignInScreen()), // Removed const for async widget
      );
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F5), 
              Color(0xFFFFFAFA), 
              Color(0xFFFFE4E1), 
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (_controller.value < 0.85)
                  ...elements.map((el) {
                    double progress = (_fallAnimation.value - el.delay) / (1.0 - el.delay);
                    progress = progress.clamp(0.0, 1.0);
                    double fallY = el.startY + (1.8 * progress); 
                    double currentX = el.startX + (sin(progress * pi * 2) * el.floatXOffset);
                    double currentY = fallY;
                    double convergeProgress = _convergeAnimation.value;
                    currentX = currentX * (1 - convergeProgress);
                    currentY = currentY * (1 - convergeProgress);
                    double scale = (1.0 - (convergeProgress * 1.0)).clamp(0.0, 1.0);
                    double opacity = (1.0 - (convergeProgress * 1.5)).clamp(0.0, 1.0);
                    double rotation = progress * pi * el.rotationSpeed;
                    return Align(
                      alignment: Alignment(currentX, currentY),
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: Transform.rotate(
                            angle: rotation,
                            child: Image.asset(
                              el.assetPath,
                              width: el.size,
                              height: el.size,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                if (_controller.value >= 0.75)
                  Center(
                    child: Opacity(
                      opacity: _logoFadeAnimation.value,
                      child: Transform.scale(
                        scale: _logoScaleAnimation.value * _pulseAnimation.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 320,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFC0CB).withOpacity(0.6), 
                                    blurRadius: 60,
                                    spreadRadius: 15,
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              mainLogoPath,
                              width: 310,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Removed automatic button logic as navigation is now handled by controller listener
              ],
            );
          },
        ),
      ),
    );
  }
}

class CloraElementNew {
  final String assetPath;
  final double startX;
  final double startY;
  final double floatXOffset;
  final double rotationSpeed;
  final double size;
  final double delay;

  CloraElementNew({
    required this.assetPath,
    required this.startX,
    required this.startY,
    required this.floatXOffset,
    required this.rotationSpeed,
    required this.size,
    required this.delay,
  });
}