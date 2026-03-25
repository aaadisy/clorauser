import 'package:clora_user/extensions/colors.dart';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/screens/user/secure_access__options_screen.dart';
import 'package:clora_user/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:terminate_restart/terminate_restart.dart';

import '../../components/common/settings_components.dart';
import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/loader_widget.dart';
import '../../extensions/new_colors.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../network/rest_api.dart';
import '../../utils/dynamic_theme.dart';
import 'backupData/back_up_screen.dart';
import 'language_screen.dart';

class InterSettingsScreen extends StatefulWidget {
  const InterSettingsScreen({super.key});

  @override
  State<InterSettingsScreen> createState() => _InterSettingsScreenState();
}

class _InterSettingsScreenState extends State<InterSettingsScreen> {
  Widget mSettingOption(String mTitle, String mImg, Function onTapCall) {
    return SettingItemWidget(
      onTap: () {
        onTapCall.call();
      },
      title: mTitle,
      leading: Image.asset(mImg, height: 20, width: 20, color: primaryColor),
      trailing: Icon(Icons.arrow_forward_ios_sharp, color: grayColor, size: 18),
      paddingAfterLeading: 10,
      paddingBeforeTrailing: 10,
    );
  }

  ///delete account api call
  Future deleteAccount(BuildContext context) async {
    appStore.setLoading(true);
    await deleteUserAccountApi().then((value) async {
      if (value.status == true) {
        logAnalyticsEvent(
            category: "app_account", action: "delete_user_account");
        await TerminateRestart.instance.restartApp(
          options: const TerminateRestartOptions(
            terminate: true,
          ),
        );
      }
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreUserData() async {
    try {
      appStore.setLoading(true);
      final result = await restoreBackupApi();
      result.fold((error) => toast("Backup not found"), (success) {
        showBackupSuccessDialog(context,
            lastBackupDate: success.data!.lastSyncDate,
            encryptedString: success.data!.encryptedUserData);
      });
    } catch (e) {
      toast("Something went wrong");
    } finally {
      appStore.setLoading(false);
    }
  }

  void showBackupSuccessDialog(BuildContext context,
      {required String lastBackupDate, required String encryptedString}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          backgroundColor: Colors.white,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mainColorLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: mainColor,
                    size: 40,
                  ),
                ),
                16.height,
                Text(
                  language.backupFound,
                  style: boldTextStyle(
                    size: 20,
                    weight: FontWeight.w600,
                    color: mainColorText,
                  ),
                ),
                8.height,
                Text(
                  '${language.restoreDataFrom} ${convertUtcToLocal2(lastBackupDate)}?',
                  style: primaryTextStyle(
                    size: 14,
                    color: mainColorBodyText,
                    weight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                24.height,
                // Buttons (adjusted padding)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // No, Don't
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10), // Reduced
                      ),
                      child: Text(
                        language.n0DoNot,
                        style: boldTextStyle(
                          color: Colors.grey[600],
                          size: 16,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Yes, Restore
                    Observer(
                      builder: (context) {
                        return ElevatedButton(
                          onPressed: () async {
                            Map<String, dynamic> data = {
                              "encryptedData": encryptedString
                            };
                            Navigator.pop(context, true);
                            appStore.setLoading(true);
                            await instance
                                .restoreBackupOfMenstrualCycleData(
                                    backupData: data,
                                    customerId: userStore.user!.id!.toString());
                            appStore.setLoading(false);
                            toast(language.dataRestored);
                            logAnalyticsEvent(
                                category: "app_data",
                                action: "restore_user_data");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10), // Reduced
                            elevation: 0,
                          ),
                          child: Text(
                            language.yesRestore,
                            style: boldTextStyle(
                              color: Colors.white,
                              size: 16,
                              weight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void deleteAppData(BuildContext c) async {
    // Close the dialog first
    Navigator.of(c, rootNavigator: true).pop();
    await Future.delayed(const Duration(milliseconds: 500));

    appStore.setLoading(true);
    await instance.clearAllData();
    appStore.setLoading(false);
    toast(language.dataCleared);

    logAnalyticsEvent(category: "app_data", action: "deleted_app_data");

    await TerminateRestart.instance.restartApp(
      options: const TerminateRestartOptions(
        terminate: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: kToolbarHeight + MediaQuery.of(context).padding.top,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                    ),
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              pop();
                            },
                            icon: Icon(CupertinoIcons.back)),
                        Text(
                          language.settings,
                          style: boldTextStyle(
                            color: Colors.black,
                            size: 20,
                            weight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    color: kPrimaryColor,
                  ),
                  Transform.translate(
                    offset: Offset(0, -25),
                    child: Container(
                        width: context.width(),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            20.height,
                            mSettingOption(language.languages, ic_language, () {
                              LanguageScreen(isFromDoctor: false)
                                  .launch(context);
                            }),
                            10.height,
                            mSettingOption(language.secureAccess, ic_lock, () {
                              SecureAccessOptionsScreen(isFromDoctor: false)
                                  .launch(context);
                            }).visible(getStringAsync(USER_TYPE) != ANONYMOUS),
                            10.height.visible(
                                getStringAsync(USER_TYPE) != ANONYMOUS),
                            mSettingOption(language.changePassword, ic_pass,
                                () {
                              //
                            }).visible(getStringAsync(USER_TYPE) != ANONYMOUS),
                            10.height,
                            mSettingOption(language.backUpData, ic_server, () {
                              BackupScreen().launch(context,
                                  shouldCheckForNetworkConnection: true);
                            }).visible(getStringAsync(USER_TYPE) == ANONYMOUS ||
                                getStringAsync(USER_TYPE) == APP_USER),
                            10.height.visible(
                                getStringAsync(USER_TYPE) == ANONYMOUS ||
                                    getStringAsync(USER_TYPE) == APP_USER),
                            mSettingOption(language.restoreData, ic_restart,
                                () async {
                              final isConnected = await isNetworkAvailable();
                              if (!isConnected) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(language
                                          .internetRequiredForThisAction),
                                      backgroundColor: ColorUtils.colorPrimary,
                                    ),
                                  );
                                }
                                return null;
                              } else {
                                toast(language.retrievingYourData);
                                restoreUserData();
                              }
                            }).visible(getStringAsync(USER_TYPE) == ANONYMOUS ||
                                getStringAsync(USER_TYPE) == APP_USER),
                            10.height.visible(
                                getStringAsync(USER_TYPE) == ANONYMOUS ||
                                    getStringAsync(USER_TYPE) == APP_USER),
                            Observer(
                              builder: (context) {
                                return mSettingOption(
                                    language.deleteAppData, ic_trash, () {
                                  showConfirmDialogCustom(
                                    image: ic_logout2,
                                    bgColor: context.cardColor,
                                    iconColor: ColorUtils.colorPrimary,
                                    context,
                                    negativeBg: context.cardColor,
                                    primaryColor: ColorUtils.colorPrimary,
                                    title: language
                                        .areYouSureYouWantToDeleteYourData,
                                    positiveText: language.yes,
                                    negativeText: language.no,
                                    height: 100,
                                    onAccept: (c) async {
                                      deleteAppData(c);
                                    },
                                  );
                                  // DeleteAppData().launch(context);
                                }).visible(
                                    getStringAsync(USER_TYPE) == ANONYMOUS ||
                                        getStringAsync(USER_TYPE) == APP_USER);
                              },
                            ),
                            10.height.visible(
                                getStringAsync(USER_TYPE) == ANONYMOUS ||
                                    getStringAsync(USER_TYPE) == APP_USER),
                            mSettingOption(language.deleteAccount, ic_trash,
                                () async {
                              final isConnected = await isNetworkAvailable();
                              if (!isConnected) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(language
                                          .internetRequiredForThisAction),
                                      backgroundColor: ColorUtils.colorPrimary,
                                    ),
                                  );
                                }
                                return null;
                              } else {
                                showConfirmDialogCustom(
                                  bgColor: context.cardColor,
                                  iconColor: ColorUtils.colorPrimary,
                                  image: ic_delete_ac,
                                  context,
                                  primaryColor: ColorUtils.colorPrimary,
                                  positiveTextColor: Colors.white,
                                  negativeTextColor: ColorUtils.colorPrimary,
                                  title: language.deleteAccount,
                                  positiveText: language.delete,
                                  height: 100,
                                  onAccept: (c) async {
                                    await deleteAccount(context);
                                  },
                                );
                              }
                            }),
                          ],
                        ).paddingSymmetric(horizontal: 16)),
                  )
                ],
              ),
            ),
            // Add this centered loader overlay
            Observer(
              builder: (context) {
                return Center(
                  child: Loader().visible(appStore.isLoading),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
