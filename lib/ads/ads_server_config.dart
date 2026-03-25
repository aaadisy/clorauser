import 'package:flutter/foundation.dart';
import 'package:clora_user/main.dart';

class FacebookAdConfig {
  static String get rewardedVideoAdId {
    if (kReleaseMode) {
      return appStore.adsConfig!.androidRewardedVideo!;
    } else if (kProfileMode) {
      return "VID_HD_9_16_39S_APP_INSTALL#" +
          appStore.adsConfig!.androidRewardedVideo!;
    } else {
      return "VID_HD_9_16_39S_APP_INSTALL#" +
          appStore.adsConfig!.androidRewardedVideo!;
    }
  }

  static String get interstitialAdId {
    if (kReleaseMode) {
      return appStore.adsConfig!.androidInterstitial!;
    } else if (kProfileMode) {
      return "IMG_16_9_APP_INSTALL" + appStore.adsConfig!.androidInterstitial!;
    } else {
      return "IMG_16_9_APP_INSTALL" + appStore.adsConfig!.androidInterstitial!;
    }
  }

  static String get bannerAdId {
    if (kReleaseMode) {
      return appStore.adsConfig!.androidBanner!;
    } else if (kProfileMode) {
      return "IMG_16_9_APP_INSTALL" + appStore.adsConfig!.androidBanner!;
    } else {
      return "IMG_16_9_APP_INSTALL" + appStore.adsConfig!.androidBanner!;
    }
  }
}
