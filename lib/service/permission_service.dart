import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart'; // Assuming 'language' object is available globally or imported elsewhere, as per original code.

/// A centralized service to handle all permission-related logic.
class PermissionService {
  // --- Feature-Specific Permission Mapping (Requirement 1) ---
  // Chat Notifications: Permission.notification (Android 13+), Handled by Push Notification flow later.
  // Voice Calls: Permission.microphone
  // Video Calls: Permission.microphone, Permission.camera
  // File Uploads: Permission.storage (or granular media permissions) - Relying on existing structure for now.

  /// Checks and requests all permissions required for communication features (chat, calls).
  ///
  /// This method requests permissions sequentially and provides clear justifications
  /// to the user. It handles cases where permissions are denied or permanently denied.
  ///
  /// Returns `true` if all essential permissions are granted, `false` otherwise.
  static Future<bool> requestCommunicationPermissions(BuildContext context) async {
    // --- Flow Start Log (Requirement 6 - context needed for calls/files) ---
    debugPrint('[PERMISSION DEBUG] Starting communication permission flow.');

    // 1. Notification Permission (For Chat Notifications)
    // This is often requested immediately upon app launch/login to enable push token registration.
    final notificationsGranted = await _requestPermission(
      context,
      Permission.notification,
      'Notifications',
      'To notify you of new messages from your doctor.',
    );
    // Log outcome for Requirement 3
    if (notificationsGranted) {
        debugPrint('[PERMISSION DEBUG] Status for Notifications: granted');
    } else {
        debugPrint('[PERMISSION DEBUG] Status for Notifications: denied (will not block chat)');
    }


    // 2. Microphone Permission (Voice Calls)
    final micGranted = await _requestPermission(
      context,
      Permission.microphone,
      'Microphone',
      'To enable audio calls and voice messages with your doctor.',
    );
    if (micGranted) {
        debugPrint('[PERMISSION DEBUG] Status for Microphone: granted');
    } else {
        debugPrint('[PERMISSION DEBUG] Status for Microphone: denied or permanently denied');
    }


    // 3. Camera Permission (Video Calls)
    final cameraGranted = await _requestPermission(
      context,
      Permission.camera,
      'Camera',
      'To enable video calls with your doctor.',
    );
    if (cameraGranted) {
        debugPrint('[PERMISSION DEBUG] Status for Camera: granted');
    } else {
        debugPrint('[PERMISSION DEBUG] Status for Camera: denied or permanently denied');
    }
    
    // 4. Storage/File Upload Permission (Placeholder for file uploads)
    // Using the storage permission which covers read/write for older APIs.
    final storageGranted = await _requestPermission(
      context,
      Permission.storage,
      'Storage/Media Access',
      'To allow you to upload images and documents to your doctor.',
    );
    if (storageGranted) {
        debugPrint('[PERMISSION DEBUG] Status for Storage: granted');
    } else {
        debugPrint('[PERMISSION DEBUG] Status for Storage: denied or permanently denied');
    }


    // NOTE on Requirement 2 (First-load explanation): This implementation handles
    // per-feature context via _showRationaleDialog. A dedicated first-launch screen
    // should be implemented outside this function if needed before full app use.
    // The flow requests permissions "in a user-friendly order."

    // Return based on a critical permission if necessary, or always true if all features can partially work.
    // For now, we return true if notifications (critical for chat list context) are granted, or proceed anyway.
    return notificationsGranted || (micGranted && cameraGranted); // Simplified success check.
  }

  /// A generic helper method to handle the logic for requesting a single permission.
  static Future<bool> _requestPermission(
    BuildContext context,
    Permission permission,
    String permissionName,
    String reason,
  ) async {
    // --- Requirement 6: Log request ---
    debugPrint('[PERMISSION DEBUG] Requested: $permissionName');

    var status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    // Handle the case where the user has permanently denied the permission.
    if (status.isPermanentlyDenied) {
      // --- Requirement 7: Handle permanently denied ---
      _showSettingsDialog(context, permissionName, reason);
      return false;
    }

    // --- Requirement 2: Show a clear explanation screen (rationale) ---
    // This dialog serves as the feature explanation before the system prompt.
    final bool didAgree = await _showRationaleDialog(context, permissionName, reason);
    if (!didAgree) {
      // --- Requirement 7: Handle general denial UX ---
      _showGuidance(context, permissionName);
      return false;
    }

    // Request the permission.
    status = await permission.request();
    
    // --- Requirement 6: Log status after request ---
    String statusString;
    if (status.isGranted) {
      statusString = 'granted';
    } else if (status.isDenied) {
      statusString = 'denied';
    } else if (status.isPermanentlyDenied) {
      statusString = 'permanently denied';
    } else {
      statusString = 'unknown (${status.toString()})';
    }
    debugPrint('[PERMISSION DEBUG] Status for $permissionName: $statusString');


    return status.isGranted;
  }

  /// Shows a dialog explaining why the permission is needed (Rationale).
  static Future<bool> _showRationaleDialog(
    BuildContext context,
    String permissionName,
    String reason,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$permissionName Permission'),
            content: Text(reason),
            actions: [
              TextButton(
                child: Text('Cancel'), // Hardcoded for simplicity, assuming language utility is unavailable
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Allow'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Informs the user that the permission is permanently denied and provides a
  /// button to open app settings (Requirement 7).
  static void _showSettingsDialog(
      BuildContext context, String permissionName, String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
            'You have permanently denied the $permissionName permission. To use this feature ($reason), please enable it from your device settings.'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Settings'),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// Shows a snackbar to inform the user that a feature may be limited (Requirement 7).
  static void _showGuidance(BuildContext context, String permissionName) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '$permissionName permission denied. This feature will be limited. Please enable it in settings for full functionality.'),
    ));
  }
}