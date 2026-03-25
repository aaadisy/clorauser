import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../extensions/shared_pref.dart';
import '../main.dart';
import '../screens/user/pass_code_screen.dart';
import 'app_common.dart';
import 'app_constants.dart';

final LocalAuthentication auth = LocalAuthentication();

enum SupportState {
  unknown,
  supported,
  unsupported,
}

Future<SupportState> checkSupport() async {
  final bool canCheckBiometrics = await auth.canCheckBiometrics;
  if (canCheckBiometrics) {
    final bool isSupported = await auth.isDeviceSupported();
    return isSupported ? SupportState.supported : SupportState.unsupported;
  } else {
    return SupportState.unsupported;
  }
}

Future<bool> authenticateUser(BuildContext context) async {
  final bool isPassLockSet = getBoolAsync(IS_PASS_LOCK_SET);
  final bool isFingerprintLockSet = getBoolAsync(IS_FINGERPRINT_LOCK_SET);

  // If both are set, prioritize fingerprint
  if (isFingerprintLockSet) {
    final SupportState supportState = await checkSupport();

    if (supportState == SupportState.supported) {
      try {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Scan your fingerprint to authenticate',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );

        debugPrint("Finger printEraAppLogs test ===> $didAuthenticate");

        if (didAuthenticate) {
          return true;
        } else {
          if (isPassLockSet) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => PassCodeScreen(isVerifyPin: true),
              ),
            );
            return false;
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error during biometric authentication: $e")),
        );

        if (isPassLockSet) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => PassCodeScreen(isVerifyPin: true),
            ),
          );
          return false;
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Your device is not supported for biometric authentication"),
        ),
      );

      if (isPassLockSet) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => PassCodeScreen(isVerifyPin: true),
          ),
        );
        return false;
      }
    }
  }

  // If only password lock is set
  if (isPassLockSet) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => PassCodeScreen(isVerifyPin: true),
      ),
    );
    return false;
  }

  return true;
}

Future<bool> setFingerPrintAuthentication(bool value) async {
  if (value) {
    if (!await auth.isDeviceSupported()) {
      toast("your device is not supported for biometric");
    } else {
      //  toast("supported");
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (canCheckBiometrics) {
        setValue(IS_FINGERPRINT_LOCK_SET, true);
        toast("Your authentication set successfully");
        return true;
      }
    }
  } else {
    cancelAuthentication();
    return false;
  }
  return false;
}

Future<void> cancelAuthentication() async {
  await auth.stopAuthentication();
  setValue(IS_FINGERPRINT_LOCK_SET, false);
}
