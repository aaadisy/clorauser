import 'dart:async';
import 'package:flutter/material.dart';
import '../ads/facebook_ads_manager.dart';
import '../main.dart';

class NavigationUtils {
  static Future<void> navigateWithPostPopAction({
    required Widget screen,
    required Future<void> Function() postPopAction,
    bool showRewardedAd = false,
    BuildContext? context,
  }) async {
    try {
      if (showRewardedAd) {
        await _showAdThenNavigate(screen, postPopAction, context);
      } else {
        await _directNavigate(screen, postPopAction, context);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      _fallbackNavigate(screen, postPopAction);
    }
  }

  static Future<void> _showAdThenNavigate(
    Widget screen,
    Future<void> Function() postPopAction,
    BuildContext? context,
  ) async {
    final completer = Completer<void>();

    // Show loading dialog using root navigator
    showDialog(
      context: context ?? navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => PopScope(
       canPop: false,
        child: AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              const Text('Loading Ad...'),
            ],
          ),
        ),
      ),
      routeSettings: const RouteSettings(name: 'adLoadingDialog'),
    );

    try {
      FacebookAdsManager.showRewardedVideoAd(
        onRewardedVideoCompleted: () => completer.complete(),
        onError: () => completer.complete(),
      );

      await completer.future;

      // Close dialog using root navigator
      if (navigatorKey.currentState?.canPop() ?? false) {
        navigatorKey.currentState?.pop();
      }

      // Navigate to new screen
      await _directNavigate(screen, postPopAction, context);
    } catch (e) {
      debugPrint('Ad showing error: $e');
      rethrow;
    }
  }

  static Future<void> _directNavigate(
    Widget screen,
    Future<void> Function() postPopAction,
    BuildContext? context,
  ) async {
    await navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => screen),
    );
    await postPopAction();
  }

  static void _fallbackNavigate(
    Widget screen,
    Future<void> Function() postPopAction,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState
          ?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => screen),
            (route) => false,
          )
          .then((_) => postPopAction());
    });
  }
}
