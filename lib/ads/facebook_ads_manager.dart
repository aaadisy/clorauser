import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';

import 'ads_server_config.dart';

class FacebookAdsManager {
  static const String appId = "1204750004531238";
  static String get interstitialAdId => FacebookAdConfig.interstitialAdId;
  static String get rewardedVideoAdId => FacebookAdConfig.rewardedVideoAdId;
  static String get bannerAdId => FacebookAdConfig.bannerAdId;
  // Initialize the Facebook Audience Network
  static Future<void> initialize() async {
    await FacebookAudienceNetwork.init(
      testingId: "d2dc00d2-45b2-45a8-9241-9fdac0a7e955",
      iOSAdvertiserTrackingEnabled: true,
    );
  }

  // Load and show Interstitial Ad with optional onDismissed callback
  static void showInterstitialAd({Function? onDismissed}) {
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: interstitialAdId,
      listener: (result, value) {
        if (result == InterstitialAdResult.LOADED) {
          FacebookInterstitialAd.showInterstitialAd();
        } else if (result == InterstitialAdResult.DISPLAYED) {
        } else if (result == InterstitialAdResult.DISMISSED) {
          if (onDismissed != null) {
            onDismissed();
          }
        } else if (result == InterstitialAdResult.ERROR) {
          // Call onDismissed even on error to proceed with download
          if (onDismissed != null) {
            onDismissed();
          }
        }
      },
    );
  }

  // Load and show Rewarded Video Ad
  static void showRewardedVideoAd({
    required Function onRewardedVideoCompleted,
    required Function onError,
  }) {
    FacebookRewardedVideoAd.loadRewardedVideoAd(
      placementId: rewardedVideoAdId,
      listener: (result, value) {
        if (result == RewardedVideoAdResult.LOADED) {
          FacebookRewardedVideoAd.showRewardedVideoAd();
        } else if (result == RewardedVideoAdResult.VIDEO_COMPLETE) {
          onRewardedVideoCompleted();
        } else if (result == RewardedVideoAdResult.ERROR) {
          onError();
        }
      },
    );
  }

  // Create and return a Banner Ad widget
  static Widget getBannerAd() {
    return Container(
      alignment: Alignment.center,
      child: FacebookBannerAd(
        placementId: bannerAdId,
        bannerSize: BannerSize.STANDARD,
        listener: (result, value) {
          if (result == BannerAdResult.LOADED) {
          } else if (result == BannerAdResult.ERROR) {}
        },
      ),
    );
  }
}
