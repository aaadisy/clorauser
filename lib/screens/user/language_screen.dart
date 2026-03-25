import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/languageConfiguration/LanguageDataConstant.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:clora_user/languageConfiguration/LanguageDefaultJson.dart';
import 'package:clora_user/languageConfiguration/ServerLanguageResponse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../extensions/animated_list/animated_list_view.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extensions.dart';
import '../../extensions/new_colors.dart';
import '../../main.dart';
import '../../utils/app_common.dart';

class LanguageScreen extends StatefulWidget {
  final bool isFromDoctor;

  const LanguageScreen({super.key, required this.isFromDoctor});

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  void initState() {
    super.initState();
    logScreenView("Language screen");
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
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: kPrimaryColor,
                child: Column(
                  children: [
                    Row(
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
                          language.languages,
                          style: boldTextStyle(
                            size: textFontSize_18,
                            weight: FontWeight.w500,
                            color: mainColorText,
                          ),
                        ),
                      ],
                    ),
                    10.height,
                  ],
                ),
              ),
              // Scrollable Content
              Expanded(
                child: Container(
                  width: context.width(),
                  decoration: const BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: AnimatedListView(
                    itemCount: defaultServerLanguageData!.length,
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      LanguageJsonData data = defaultServerLanguageData![index];
                      bool isSelected = getStringAsync(
                            SELECTED_LANGUAGE_CODE,
                            defaultValue: defaultLanguageCode,
                          ) ==
                          data.languageCode.validate();

                      return GestureDetector(
                        onTap: () async {
                          bool confirm = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.white.withValues(alpha: 0.95),
                                title: Text(
                                  language.restartRequired,
                                  style: boldTextStyle(
                                      size: 18, color: Colors.black87),
                                ),
                                content: Text(
                                  language.toApplyTheLanguageChanges,
                                  style: secondaryTextStyle(
                                      size: 14, color: Colors.black54),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                      language.cancel,
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      language.Confirm,
                                      style: const TextStyle(color: mainColor),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm) {
                            await updateAppLanguageConfiguration(
                                    data: data, context: context)
                                .whenComplete(
                              () {
                                TerminateRestart.instance.restartApp(
                                  options: const TerminateRestartOptions(
                                      terminate: true),
                                );
                              },
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? mainColor.withValues(alpha: 0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected
                                  ? mainColor.withValues(alpha:  0.5)
                          : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Flag icon (uncomment if you want to include)
                              // ClipRRect(
                              //   borderRadius: BorderRadius.circular(8),
                              //   child: Image.asset(
                              //     data.flag.validate(),
                              //     width: 28,
                              //     height: 28,
                              //     fit: BoxFit.cover,
                              //   ),
                              // ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  data.languageName.validate(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isSelected ? mainColor : Colors.black87,
                                  ),
                                ),
                              ),
                              AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: isSelected ? 1.1 : 1.0,
                                child: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 24,
                                  color: isSelected
                                      ? mainColor
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
