
import 'package:clora_user/extensions/extension_util/context_extensions.dart';

import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../../../extensions/new_colors.dart';
import '../../../network/rest_api.dart';
import '../../../utils/app_common.dart';
import '../../../utils/app_constants.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool backupData = false;
  bool isBackingUp = false;

  @override
  void initState() {
    super.initState();
    initSwitchState();
    logScreenView("Backup screen");
  }

  void initSwitchState() {
    final value = getBoolAsync(IS_BACKUP_ENABLED, defaultValue: false);
    setState(() {
      backupData = value;
    });
  }

  Future<void> backupMyData({required bool value}) async {
    appStore.setLoading(true);
    Map<String, String> req = {
      "is_backup": value ? "on" : "off",
    };
    final result = await backupUserData(req);
    if (result.status == true) {
      setState(() {
        backupData = value;
      });
      appStore.setLoading(false);
      setValue(IS_BACKUP_ENABLED, value);
      toast(result.message);
      logAnalyticsEvent(category: "app_data", action: "auto_backup_enabled");
    } else {
      appStore.setLoading(false);
      toast(result.message);
    }
  }

  Future<void> performManualBackup() async {
    setState(() {
      isBackingUp = true;
    });
    try {
      final now = DateTime.now();
      final result = await instance.getBackupOfMenstrualCycleData();
      final encryptedData = result['encryptedData'] as String?;

      if (encryptedData != null && encryptedData.isNotEmpty) {
        Map req = {"encrypted_user_data": encryptedData};
        final result = await manualBackupData(req);
        if (result.status == true) {
          await setValue(LAST_DATA_SYNC_DATETIME, now.toIso8601String());
          toast(language.backupSuccessText);
          logAnalyticsEvent(
              category: "app_data", action: "manual_backup_performed");
        } else {
          toast('Backup failed: No data returned.');
        }
      }
    } catch (e) {
      toast('Backup failed: $e');
    } finally {
      setState(() {
        isBackingUp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Custom Header
                  Container(
                    color: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            CupertinoIcons.back,
                            color: mainColorText,
                          ),
                        ),
                        Text(
                          language.backUpData,
                          style: boldTextStyle(
                            size: textFontSize_18,
                            weight: FontWeight.w500,
                            color: mainColorText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Main Content Area
                  Expanded(
                    child: Container(
                      width: context.width(),
                      decoration: const BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Scrollable Content
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Auto Backup Toggle
                                  reminderCommon(
                                    language.autoBackup,
                                    language.backupPerFormedEvery,
                                    color: Colors.white,
                                    borderRadius: 12,
                                    CupertinoSwitch(
                                      activeTrackColor: mainColor,
                                      value: backupData,
                                      onChanged: (value) {
                                        backupMyData(value: value);
                                      },
                                    ),
                                  ).paddingSymmetric(vertical: 10),
                                  // Manual Backup Button
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.backup,
                                              color: mainColor,
                                              size: 24,
                                            ),
                                            12.width,
                                            Text(
                                              language.manualBackup,
                                              style: boldTextStyle(
                                                color: mainColorText,
                                                size: 16,
                                                weight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        8.height,
                                        Text(
                                          'Create a secure backup of your current data',
                                          style: secondaryTextStyle(
                                            size: textFontSize_12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        16.height,
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: isBackingUp
                                                ? null
                                                : performManualBackup,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: mainColor,
                                              disabledBackgroundColor:
                                                  mainColor.withValues(alpha:  0.5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              elevation: 0,
                                            ),
                                            child: isBackingUp
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      8.width,
                                                      Text(
                                                        language.backingUp,
                                                        style: boldTextStyle(
                                                          size: textFontSize_16,
                                                          weight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.cloud_upload,
                                                        size: 20,
                                                        color: Colors.white,
                                                      ),
                                                      8.width,
                                                      Text(
                                                        language.backupNow,
                                                        style: boldTextStyle(
                                                          size: textFontSize_16,
                                                          weight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).paddingSymmetric(vertical: 10),
                                  // Last Backup Info (Optional)
                                  if (getStringAsync(LAST_DATA_SYNC_DATETIME)
                                      .isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.history,
                                            color: Colors.grey[600],
                                            size: 24,
                                          ),
                                          12.width,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  language.lastBackup,
                                                  style: secondaryTextStyle(
                                                    size: textFontSize_14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                4.height,
                                                Text(
                                                  formatDateTime(DateTime.parse(
                                                      getStringAsync(
                                                          LAST_DATA_SYNC_DATETIME))),
                                                  style: boldTextStyle(
                                                    size: textFontSize_16,
                                                    weight: FontWeight.w500,
                                                    color: mainColorText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).paddingSymmetric(vertical: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Full-screen centered CircularProgressIndicator
            Observer(
              builder: (context) {
                return Center(
                  child: Loader(),
                ).visible(appStore.isLoading);
              },
            )
          ],
        ),
      ),
    );
  }

  // DateTime formatter
  String formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('MMM, yyyy h:mm a');
    final formattedDate = dateFormat.format(dateTime);
    final day = dateTime.day;
    final ordinal = _getOrdinalSuffix(day);
    return '${day}$ordinal $formattedDate';
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
